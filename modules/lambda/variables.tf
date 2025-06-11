variable "lambda_function" {
  description = "Configuration of lambda function"

  type = object({
    function_name = string
    role          = string
    filename      = string
    handler       = string
    runtime       = string
  })
}
