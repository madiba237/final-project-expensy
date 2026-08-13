# Documentation Monitoring & Logging - Cluster EKS `eks-alain`

Ce projet utilise **Prometheus & Grafana** pour la collecte et la visualisation des métriques, et **AWS Fluent Bit** pour l'envoi des logs applicatifs vers **AWS CloudWatch**.

---

## 1. Déploiement de la Stack Monitoring (Prometheus & Grafana)

### Prérequis
- `helm` et `kubectl` installés et configurés sur le cluster `eks-alain`.

### Étapes d'installation

1. **Ajouter les dépôts Helm :**
   ```bash
   helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
   helm repo update