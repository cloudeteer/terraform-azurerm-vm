variable "example_variable" {
  description = "Example variable (between 3 and 13 characters)"
  type        = string

  validation {
    condition     = length(var.example_variable) >= 3 && length(var.example_variable) <= 13
    error_message = "Example variable must be between 3 and 13 characters"
  }
}
