/*
 Terraform 0.11.* doesn't support dynamic list of maps.
 The proposed hack will create and inject this list of maps from a list of string.
 In order to create a dynamic list of instance types in the autoscaling group
 We use an intermediate null_data_source in order to transform an array of string to a list of map
 links:
  - https://github.com/HENNGE/terraform-aws-autoscaling-mixed-instances/blob/master/locals.tf#L17
  - https://github.com/HENNGE/terraform-aws-autoscaling-mixed-instances/blob/master/main.tf#L77

 INPUT: ["t1.micro", "t2.micro", "m5.large"]
 OUTPUT:
 ...
 override {
   instance_type = "t1.micro",
 }

 override {
   instance_type = "t2.micro",
 }

 override {
   instance_type = "m5.large",
 }
*/
data "null_data_source" "prometheus-instance_types" {
  count = "${length(var.prometheus-spot-instance-types)}"

  inputs = "${map(
    "instance_type", trimspace(element(var.prometheus-spot-instance-types, count.index))
  )}"
}