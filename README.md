## Deploying the Application Locally

To deploy the application locally, follow these steps:

1.  **Ensure you have the necessary tools installed:**

    - [Helm](https://helm.sh/docs/intro/install/)
    - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
    - A running Kubernetes cluster (e.g., [Minikube](https://minikube.sigs.k8s.io/docs/start/))

2.  **Run the deployment script:**

    ```bash
    ./deploy.sh
    ```

    By default, this will deploy the application in the `dev` environment. ~~To specify a different environment, pass the environment name as an argument:~~ Currently only dev environment is supported

3.  **Verify the deployment:**

    - Check the status of the Helm releases:
      ```bash
      helm list -n remarket
      ```
    - Get the details of the Ingress:
      ```bash
      kubectl get ingress -n remarket
      ```

4.  **Access the application:**
    By default kubernetes does not allow external trafic goin into the cluster. To access the application you need to forward port from you local machine to the kubernetes cluster.

    ### Important notice

    To access application you MUST use host name i.e. localhost. This is done because, nginx can resolve only proper DNS names, which 127.0.0.1 IP does not satisfy.

    ### Minikube

    ```
    minikube service remarket-ingress-nginx-controller --url -n remarket
    ```

    Please note output may look something like:

    ```
    http://127.0.0.1:43489
    http://127.0.0.1:39733
    ❗ Because you are using a Docker driver on linux, the terminal needs to be open to run it.
    ```

    There is 2 IPs, because NGINX, exports both 80 and 443 ports. The first port is the mapped to 80.

    ### Local kubernetes (ex. Docker desktop)

    ```
    kubectl port-forward --namespace=remarket service/remarket-ingress-nginx-controller 80:80
    ```

5.  **Delete aplication:**
    To uninstall remarket simply run:
    ```
    helm uninstall remarket -n remarket
    ```
