# Kubectl Apply Declarative Resource Management

This example demonstrates the core functionality of `kubectl apply` for declarative resource management in Kubernetes. It shows how to create a Deployment, then update its image version and replica count using the same `kubectl apply` command, highlighting its ability to reconcile desired state with current cluster state. The script also uses `kubectl diff` to preview changes before applying them.

## Language

`bash`

## How to Run

1. Ensure `kubectl` is installed and configured to access a Kubernetes cluster.
2. Save the code as `apply_demo.sh`.
3. Run `bash apply_demo.sh` in your terminal.

## Original Article

This example accompanies the Turkish article: [Kubectl Apply Komutunun Perde Arkası: Kaynak Yönetimi ve Senkronizasyon](https://fatihsoysal.com/blog/kubectl-apply-komutunun-perde-arkasi-kaynak-yonetimi-ve-senkronizasyon/).

## License

MIT — see [LICENSE](LICENSE).
