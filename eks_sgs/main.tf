resource "aws_security_group" "eks-node-public" {
  name        = "eks-node-public-${var.env}"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${
    map(
     "kubernetes.io/cluster/${var.eks_name}", "shared",
     "Name", "eks-node-public-${var.env}"
    )
  }"
}

resource "aws_security_group_rule" "eks-master-ingress-node-public" {
  description              = "Allow pods to communicate with the master API Server"
  from_port                = 0
  protocol                 = "all"
  security_group_id        = "${var.eks_sg_id}"
  source_security_group_id = "${aws_security_group.eks-node-public.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-master-public" {
  description              = "Allow worker Kubelets and pods to receive communication from the master control plane"
  from_port                = 0
  protocol                 = "all"
  security_group_id        = "${aws_security_group.eks-node-public.id}"
  source_security_group_id = "${var.eks_sg_id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-self-public" {
  description              = "Allow worker Kubelets and pods to talk to each other"
  from_port                = 0
  protocol                 = "all"
  security_group_id        = "${aws_security_group.eks-node-public.id}"
  source_security_group_id = "${aws_security_group.eks-node-public.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group" "eks-node-private" {
  name        = "eks-node-private-${var.env}"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${
    map(
     "kubernetes.io/cluster/${var.eks_name}", "shared",
     "Name", "eks-node-private-${var.env}"
    )
  }"
}

resource "aws_security_group_rule" "eks-master-ingress-node-private" {
  description              = "Allow pods to communicate with the master API Server"
  from_port                = 0
  protocol                 = "all"
  security_group_id        = "${var.eks_sg_id}"
  source_security_group_id = "${aws_security_group.eks-node-private.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-master-private" {
  description              = "Allow worker Kubelets and pods to receive communication from the master control plane"
  from_port                = 0
  protocol                 = "all"
  security_group_id        = "${aws_security_group.eks-node-private.id}"
  source_security_group_id = "${var.eks_sg_id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-self-private" {
  description              = "Allow worker Kubelets and pods to talk to each other"
  from_port                = 0
  protocol                 = "all"
  security_group_id        = "${aws_security_group.eks-node-private.id}"
  source_security_group_id = "${aws_security_group.eks-node-private.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group" "eks-node-environment" {
  name        = "eks-node-region-${var.env}"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = "${
    map(
     "kubernetes.io/cluster/${var.eks_name}", "shared"
    )
  }"
}

resource "aws_security_group_rule" "eks-node-53-environment" {
  description              = "Allow DNS"
  from_port                = 53
  protocol                 = "udp"
  security_group_id        = "${aws_security_group.eks-node-environment.id}"
  cidr_blocks              = [var.cidr]
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-self-region" {
  description              = "Temp rule during set up. Allows all nodes to connect to each other."
  from_port                = 0
  protocol                 = "all"
  security_group_id        = "${aws_security_group.eks-node-environment.id}"
  source_security_group_id = "${aws_security_group.eks-node-environment.id}"
  to_port                  = 65535
  type                     = "ingress"
}