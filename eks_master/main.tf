resource "aws_iam_user" "eks" {
  name = "${var.eks_name}"
  path = "/"
}

resource "aws_iam_user_policy" "eks_policy" {
  name = "eks_policy-${var.eks_name}"
  user = "${aws_iam_user.eks.name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "*"
             ],
             "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_access_key" "eks" {
  user = "${aws_iam_user.eks.name}"
}

resource "aws_iam_role" "eks-admin" {
  name = "eks_admin-${var.eks_name}"
  assume_role_policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Principal":{
        "AWS":"${aws_iam_user.eks.arn}"
      },
      "Action":"sts:AssumeRole",
      "Condition":{}
    }
  ]
}
POLICY
}

resource "aws_iam_role" "eks" {
  name = "${var.eks_name}"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "eks_master_elb" {
  name        = "elb-policy-${var.eks_name}"
  description = "elb-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetServiceLinkedRoleDeletionStatus",
                "iam:CreateServiceLinkedRole",
                "iam:DeleteServiceLinkedRole"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "kubernetes-logs" {
  name        = "kubernetes-logs-policy-${var.eks_name}"
  description = "kubernetes-logs-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "logs",
            "Effect": "Allow",
            "Action": [
              "logs:*",
              "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*",
                "arn:aws:s3:::*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy" "kubernetes-autoscaling" {
  name        = "kubernetes-autoscaling-policy-${var.tags["environment"]}"
  description = "kubernetes-autoscaling-policy-${var.tags["environment"]}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "eks_nodes" {
  name = "eks_nodes-${var.eks_name}"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-master-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks.name}"
}

resource "aws_iam_role_policy_attachment" "eks-master-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks_nodes.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks_nodes.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks_nodes.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-logging" {
  policy_arn = "${aws_iam_policy.kubernetes-logs.arn}"
  role       = "${aws_iam_role.eks_nodes.name}"
}

resource "aws_iam_role_policy_attachment" "eks-node-autoscaling" {
  policy_arn = "${aws_iam_policy.kubernetes-autoscaling.arn}"
  role       = "${aws_iam_role.eks_nodes.name}"
}

resource "aws_security_group" "eks-node-global" {
  name        = "eks-node-global"
  description = "Communication between worker nodes"
  vpc_id      = "${var.vpc_id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${merge(map(
    "Name", "eks-node-global",
    "kubernetes.io/cluster/${var.eks_name}", "shared"),
    var.tags
  )}"
}

resource "aws_security_group_rule" "eks-node-global-dns-tcp" {
  description              = "Allow to communicate with the cluster API Server"
  from_port                = 53
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-node-global.id}"
  self                     = true
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-global-dns-udp" {
  description              = "Allow to communicate with the cluster API Server"
  from_port                = 53
  protocol                 = "udp"
  security_group_id        = "${aws_security_group.eks-node-global.id}"
  self                     = true
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-global-heapster" {
  description              = "Allow to communicate with the cluster API Server"
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-node-global.id}"
  self                     = true
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-global-influxdb" {
  description              = "Allow to communicate with the cluster API Server"
  from_port                = 8086
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-node-global.id}"
  self                     = true
  to_port                  = 8086
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-global-all" {
  description              = "Allow to communicate with the cluster API Server"
  from_port                = 0
  protocol                 = "all"
  security_group_id        = "${aws_security_group.eks-node-global.id}"
  self                     = true
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group" "eks" {
  name        = "eks"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${merge(map(
    "Name", "${var.eks_name}",
    "kubernetes.io/cluster/${var.eks_name}", "shared"),
    var.tags
  )}"
}

resource "aws_security_group_rule" "eks-master-ingress-metrics" {
  cidr_blocks       = ["10.10.0.0/16"]
  description       = "Metrics master API Server"
  from_port         = 10251
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks.id}"
  to_port           = 10251
  type              = "ingress"
}

resource "aws_cloudwatch_log_group" "kubernetes" {
  name = "kubernetes-${var.eks_name}"
  retention_in_days = "180"
  tags = "${var.tags}"
}

resource "aws_eks_cluster" "eks" {
  name            = "${var.eks_name}"
  role_arn        = "${aws_iam_role.eks.arn}"
  enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]
  vpc_config {
    security_group_ids = ["${aws_security_group.eks.id}"]
    subnet_ids         = var.eks_subnet_ids
    endpoint_private_access = "true"
  }
  depends_on = [
    "aws_iam_role_policy_attachment.eks-master-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eks-master-AmazonEKSServicePolicy",
  ]
}

resource "aws_iam_instance_profile" "eks-nodes" {
  name = "eks-nodes-${var.eks_name}"
  role = "${aws_iam_role.eks_nodes.name}"
}

locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks_nodes.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.eks_name}"

KUBECONFIG
}