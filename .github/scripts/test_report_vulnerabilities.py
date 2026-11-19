import importlib.util
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "report_vulnerabilities", Path(__file__).with_name("report_vulnerabilities.py")
)
reporter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reporter)


class ReportingTests(unittest.TestCase):
    def test_real_scan_formats(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "trivy.sarif").write_text(
                json.dumps(
                    {
                        "runs": [
                            {
                                "results": [
                                    {"ruleId": "CVE-2026-1234"},
                                    {"ruleId": "CVE-2026-1234"},
                                    {"ruleId": "AVD-CONFIG-0001"},
                                ]
                            }
                        ],
                    }
                )
            )
            (root / "wiz.json").write_text(
                json.dumps(
                    {
                        "status": {"state": "SUCCESS"},
                        "packages": [
                            {
                                "name": "openssl",
                                "version": "1",
                                "vulnerabilityFindings": {
                                    "severities": {"criticalCount": 0, "lowCount": 1},
                                    "fixedVersion": "2",
                                },
                            },
                            {
                                "name": "clean",
                                "version": "1",
                                "vulnerabilityFindings": {
                                    "severities": {"highCount": 0}
                                },
                            },
                        ],
                    }
                )
            )
            findings, errors = reporter.scan_findings(root)
            self.assertEqual(errors, [])
            self.assertEqual(findings[0]["CVEs"], ["CVE-2026-1234"])
            self.assertEqual(
                findings[1]["packages"],
                [
                    {
                        "name": "openssl",
                        "version": "1",
                        "severities": {"criticalCount": 0, "lowCount": 1},
                        "fixedVersion": "2",
                    }
                ],
            )

    def test_missing_and_broken_reports_fail(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.assertTrue(reporter.scan_findings(root)[1])
            report = root / "wiz.json"
            report.write_text(
                json.dumps({"status": {"state": "FAILED"}, "packages": []})
            )
            self.assertTrue(reporter.scan_findings(root)[1])
            report.write_text("{}")
            self.assertTrue(reporter.scan_findings(root)[1])

    def test_failed_scan_does_not_hide_other_findings(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "coverage.json").write_text(
                json.dumps(
                    {
                        "trivy": "success",
                        "wizcli": "failure",
                    }
                )
            )
            (root / "trivy.sarif").write_text(
                json.dumps(
                    {
                        "runs": [{"results": [{"ruleId": "CVE-2026-1234"}]}],
                    }
                )
            )
            (root / "broken.json").write_text("{")
            findings, errors = reporter.scan_findings(root)
            self.assertEqual(findings[0]["CVEs"], ["CVE-2026-1234"])
            self.assertEqual(len(errors), 2)

    def test_clean_scan_has_no_github_side_effects(self):
        with patch.object(reporter, "gh") as gh:
            reporter.report_issue([], "Production", "https://example.test/run")
            gh.assert_not_called()

    def test_open_issue_update_does_not_retrigger_label_alert(self):
        existing = [
            {
                "number": 9,
                "body": "<!-- images-connect-vulnerabilities:Content Image -->",
                "state": "open",
                "labels": ["blocking"],
            }
        ]
        with patch.object(reporter, "gh", side_effect=[existing, {}, {}]) as gh:
            reporter.report_issue([{"CVEs": ["CVE-2026-1234"]}], "Content Image", "run")
            self.assertEqual(gh.call_count, 3)
            self.assertIn("PATCH", gh.call_args_list[1].args)
            self.assertEqual(
                gh.call_args_list[2].kwargs["payload"], {"labels": ["blocking"]}
            )

    def test_new_issue_mentions_team_and_adds_label_separately(self):
        with patch.object(
            reporter, "gh", side_effect=[[], {"number": 123}, None]
        ) as gh:
            reporter.report_issue(
                [{"CVEs": ["CVE-2026-1234"]}], "Development", "run-url"
            )
            create = gh.call_args_list[1]
            self.assertEqual(
                create.kwargs["payload"]["title"],
                "Container image vulnerabilities: Development",
            )
            self.assertIn("@posit-dev/connect", create.kwargs["payload"]["body"])
            self.assertIn("run-url", create.kwargs["payload"]["body"])
            self.assertNotIn("labels", create.kwargs["payload"])
            self.assertEqual(
                gh.call_args_list[2].kwargs["payload"], {"labels": ["blocking"]}
            )
            self.assertIn(
                "repos/posit-dev/connect/issues/123/labels", gh.call_args_list[2].args
            )

    def test_repeat_reopens_managed_issue_without_duplicate(self):
        existing = [
            {"number": 1, "body": "unrelated", "state": "open"},
            {
                "number": 2,
                "body": "<!-- images-connect-vulnerabilities:Production -->",
                "state": "closed",
                "labels": ["blocking"],
            },
        ]
        with patch.object(reporter, "gh", side_effect=[existing, None, {}, {}]) as gh:
            reporter.report_issue([{"packages": ["affected"]}], "Production", "new-run")
            self.assertIn("DELETE", gh.call_args_list[1].args)
            self.assertIn(
                "repos/posit-dev/connect/issues/2/labels/blocking",
                gh.call_args_list[1].args,
            )
            update = gh.call_args_list[2]
            self.assertIn("PATCH", update.args)
            self.assertIn("repos/posit-dev/connect/issues/2", update.args)
            self.assertEqual(update.kwargs["payload"]["state"], "open")
            self.assertIn("new-run", update.kwargs["payload"]["body"])


if __name__ == "__main__":
    unittest.main()
