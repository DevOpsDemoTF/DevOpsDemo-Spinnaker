locals {
  merged_kube_conf = "${path.module}/.generated/merged_kube_config"
}

data "template_file" "k8s_clusters" {
  template = file("${path.module}/templates/kube.yaml")
  vars     = {
    secret_name = kubernetes_secret.merged_kube_config.metadata.0.name
    secret_key = "merged"
    contexts    = join("\n", [for e in var.environments: "    - ${e.context}"])
    deployment = var.environments[0].context
  }
}

resource "kubernetes_secret" "merged_kube_config" {
  metadata {
    name = "kube-config"
    namespace = kubernetes_namespace.spinnaker.metadata.0.name
  }

  data = {
    merged = data.local_file.merged_kube_conf.content
  }
}

data "local_file" "merged_kube_conf" {
  filename = local.merged_kube_conf

  depends_on = [null_resource.merge_kube_conf]
}

# see https://ahmet.im/blog/mastering-kubeconfig/
resource "null_resource" "merge_kube_conf" {
  triggers = {
    kube_confs = sha256(join("\n", local_file.kube_conf.*.sensitive_content))
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = join(":", local_file.kube_conf.*.filename)
    }
    command = "kubectl config view --merge --flatten > '${local.merged_kube_conf}'"
  }
}

resource "local_file" "kube_conf" {
  count = length(var.environments)

  filename = "${path.module}/.generated/kube_config_${count.index}"
  sensitive_content = var.environments[count.index].kube_conf
}
