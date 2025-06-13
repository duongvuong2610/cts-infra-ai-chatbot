resource "aws_cloudwatch_event_rule" "scheduled_crawling_jobs" {
  name        = "scheduled_crawling_jobs"
  description = "Rule for scheduling crawling web data"

  schedule_expression = "rate(30 minutes)"

  state = "DISABLED"
}
