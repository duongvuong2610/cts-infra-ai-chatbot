resource "aws_cloudwatch_event_rule" "scheduled_crawling_jobs" {
  name        = "scheduled_crawling_jobs"
  description = "Rule for scheduling crawling web data"

  schedule_expression = "rate(30 minutes)"

  state = "DISABLED"
}

resource "aws_cloudwatch_event_rule" "scheduled_data_enriching_jobs" {
  name        = "scheduled_data_enriching_jobs"
  description = "Rule for scheduling enriching data"

  schedule_expression = "rate(45 minutes)"

  state = "DISABLED"
}

