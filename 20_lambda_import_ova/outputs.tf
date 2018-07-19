output "arn1" {
    value = "${aws_cloudformation_stack.sns-topic-first.outputs["ARN"]}"
}

output "arn2" {
    value = "${aws_cloudformation_stack.sns-topic-second.outputs["ARN"]}"
}
