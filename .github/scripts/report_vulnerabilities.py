"""Report container scan findings to the Connect team."""

import json
import os
import re
import subprocess
import sys
from pathlib import Path

REPOSITORY = "posit-dev/connect"
CVE = re.compile(r"CVE-\d{4}-\d{4,}")


def report_findings(report, directory):
    data = json.loads(report.read_text())
    source = str(report.relative_to(directory))
    if report.suffix == ".sarif":
        ids = {
            result["ruleId"]
            for run in data["runs"]
            for result in run["results"]
            if CVE.fullmatch(result["ruleId"])
        }
        return {"report": source, "CVEs": sorted(ids)} if ids else None
    if data["status"]["state"] != "SUCCESS":
        raise ValueError("Wiz scan did not complete")
    packages = []
    for package in data["packages"]:
        vulnerability = package["vulnerabilityFindings"]
        if sum(vulnerability["severities"].values()) > 0:
            packages.append(
                {
                    "name": package["name"],
                    "version": package["version"],
                    "severities": vulnerability["severities"],
                    "fixedVersion": vulnerability.get("fixedVersion"),
                }
            )
    return {"report": source, "packages": packages} if packages else None


def scan_findings(directory):
    reports = sorted(directory.rglob("*.sarif")) + sorted(directory.rglob("*.json"))
    findings, errors = [], []
    scan_reports = 0
    for report in reports:
        try:
            if report.name == "coverage.json":
                coverage = json.loads(report.read_text())
                for scanner, outcome in coverage.items():
                    if outcome not in {"success", "skipped"}:
                        errors.append(f"{report}: {scanner} scan {outcome}")
                if coverage["trivy"] == "success" and not list(
                    report.parent.rglob("*.sarif")
                ):
                    errors.append(f"{report}: Trivy succeeded without a report")
                continue
            scan_reports += 1
            finding = report_findings(report, directory)
            if finding:
                findings.append(finding)
        except (ValueError, KeyError, TypeError) as error:
            errors.append(f"{report}: invalid scan report ({error})")
    if not scan_reports:
        errors.append(
            "No vulnerability reports were produced; scan coverage is unknown"
        )
    return findings, errors


def gh(*arguments, payload=None):
    result = subprocess.run(
        ["gh", *arguments],
        input=json.dumps(payload) if payload is not None else None,
        text=True,
        capture_output=True,
        check=True,
    )
    return json.loads(result.stdout) if result.stdout.strip() else None


def report_issue(findings, workflow, run_url):
    if workflow not in {"Production", "Development", "Content Image"}:
        raise ValueError(f"Unexpected scan workflow: {workflow}")
    marker = f"<!-- images-connect-vulnerabilities:{workflow} -->"
    if not findings:
        print("No vulnerabilities reported. Existing issues require manual resolution.")
        return
    detail = json.dumps(findings, indent=2).replace("```", r"\u0060\u0060\u0060")
    # GitHub issue bodies are limited to 65536 characters; artifacts retain full details.
    if len(detail) > 55000:
        detail = detail[:55000] + "\n[Truncated; see scan artifacts for all findings]"
    body = (
        f"{marker}\n@posit-dev/connect\n\n"
        f"Container vulnerability findings from the **{workflow}** workflow.\n\n"
        f"Scan run and full report artifacts: {run_url}\n\n"
        "Review and resolve these findings before release. "
        "Scan findings are audit-only; Connect CI does not wait for this run.\n\n"
        "Wiz reports package severity counts; Trivy reports individual CVE IDs.\n\n"
        f"```json\n{detail}\n```\n"
    )
    issues = gh(
        "api",
        "--paginate",
        "--slurp",
        f"repos/{REPOSITORY}/issues?state=all&creator=posit-connect-projects%5Bbot%5D&per_page=100",
        "--jq",
        "[.[][] | select(.pull_request == null) | {number, body, state, labels: [.labels[].name]}]",
    )
    existing = next(
        (issue for issue in issues if marker in (issue["body"] or "")), None
    )
    if existing:
        endpoint = f"repos/{REPOSITORY}/issues/{existing['number']}"
        if existing["state"] == "closed" and "blocking" in existing["labels"]:
            gh("api", "--method", "DELETE", f"{endpoint}/labels/blocking")
        gh(
            "api",
            "--method",
            "PATCH",
            endpoint,
            "--input",
            "-",
            payload={
                "body": body,
                "state": "open",
            },
        )
        gh(
            "api",
            "--method",
            "POST",
            f"{endpoint}/labels",
            "--input",
            "-",
            payload={
                "labels": ["blocking"],
            },
        )
        print(f"Updated blocking issue #{existing['number']}")
        return
    issue = gh(
        "api",
        "--method",
        "POST",
        f"repos/{REPOSITORY}/issues",
        "--input",
        "-",
        payload={
            "title": f"Container image vulnerabilities: {workflow}",
            "body": body,
        },
    )
    # Adding the label separately triggers Connect's issues:labeled Slack alert.
    gh(
        "api",
        "--method",
        "POST",
        f"repos/{REPOSITORY}/issues/{issue['number']}/labels",
        "--input",
        "-",
        payload={"labels": ["blocking"]},
    )
    print(f"Created blocking issue #{issue['number']}")


if __name__ == "__main__":
    findings, errors = scan_findings(Path("vulnerability-reports"))
    report_issue(
        findings,
        os.environ["SCAN_WORKFLOW"],
        os.environ["SCAN_RUN_URL"],
    )
    for error in errors:
        print(error, file=sys.stderr)
    sys.exit(1 if errors else 0)
