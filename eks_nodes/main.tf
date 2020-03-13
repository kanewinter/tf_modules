data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-1*"]
  }
  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

locals {
  public-eks-node-userdata = <<USERDATA
#!/bin/bash -xe
/etc/eks/bootstrap.sh "${local.eks_name}" --kubelet-extra-args '--node-labels=kubelet.kubernetes.io/environment="${var.tags["environment"]}",kubelet.kubernetes.io/zone=public'
USERDATA
  private-eks-node-userdata = <<USERDATA
#!/bin/bash -xe
/etc/eks/bootstrap.sh "${local.eks_name}" --kubelet-extra-args '--node-labels=kubelet.kubernetes.io/environment="${var.tags["environment"]}",kubelet.kubernetes.io/zone=private'
USERDATA
  eks_name = "eks_${var.tags["environment"]}"
  deploy_key = "deploy-key-${var.tags["environment"]}"
}

resource "aws_launch_configuration" "eks_public" {
  associate_public_ip_address = true
  iam_instance_profile        = "${var.eks_node_instance_profile}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.eks_node_public_instance_type}"
  name_prefix                 = "${var.tags["environment"]}-eks-public-"
  security_groups             = ["${var.eks_node_public_sg_id}", "${var.eks_node_environment_sg_id}"]
  user_data_base64            = "${base64encode(local.public-eks-node-userdata)}"
  key_name                    = "${local.deploy_key}"
  enable_monitoring           = true
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_launch_configuration" "eks_private" {
  associate_public_ip_address = true
  iam_instance_profile        = "${var.eks_node_instance_profile}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.eks_node_private_instance_type}"
  name_prefix                 = "${var.tags["environment"]}-eks-private-"
  security_groups             = ["${var.eks_node_private_sg_id}", "${var.eks_node_environment_sg_id}"]
  user_data_base64            = "${base64encode(local.private-eks-node-userdata)}"
  key_name                    = "${local.deploy_key}"
  enable_monitoring           = true
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "eks_public" {
  launch_configuration = "${aws_launch_configuration.eks_public.id}"
  max_size             = "${var.eks_node_public_max_size}"
  min_size             = "${var.eks_node_public_min_size}"
  name                 = "${var.tags["environment"]}-eks-public"
  vpc_zone_identifier  = "${var.public_eks_subnet_ids}"
  wait_for_capacity_timeout = "30m"
  min_elb_capacity = 1
  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  tag {
    key                 = "kubelet.kubernetes.io/zone"
    value               = "public"
    propagate_at_launch = true
  }
  tag {
    key                 = "environment"
    value               = "${var.tags["environment"]}"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "${var.tags["environment"]}-eks-public"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${local.eks_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "eks_private" {
  launch_configuration = "${aws_launch_configuration.eks_private.id}"
  max_size             = "${var.eks_node_private_max_size}"
  min_size             = "${var.eks_node_private_min_size}"
  name                 = "${var.tags["environment"]}-eks-private"
  vpc_zone_identifier  = "${var.private_eks_subnet_ids}"
  wait_for_capacity_timeout = "30m"
  min_elb_capacity = 1
  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  tag {
    key                 = "kubelet.kubernetes.io/zone"
    value               = "private"
    propagate_at_launch = true
  }
  tag {
    key                 = "environment"
    value               = "${var.tags["environment"]}"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "${var.tags["environment"]}-eks-private"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${local.eks_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_eks_public" {
  name                   = "eks-scale-${var.tags["environment"]}"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 300
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
  autoscaling_group_name = "${aws_autoscaling_group.eks_public.name}"
}

resource "aws_autoscaling_policy" "cpu_eks_private" {
  name                   = "eks-scale-${var.tags["environment"]}"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 300
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
  autoscaling_group_name = "${aws_autoscaling_group.eks_private.name}"
}
