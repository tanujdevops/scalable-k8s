# DevOps Engineer Exercise Solution

The exercise focuses on deploying two containers that run independent APIs to return data from their respective isolated databases. We need to scale these containers independently; based on CPU utilization and ensure they can handle rolling deployments and rollbacks. Additionally, we want to implement IAM controls to restrict developer access to run certain commands.

### Solution Overview
I will deploy two Kubernetes deployments for each container, each with its own replica set. These deployments will have their own services to expose the pods within the Kubernetes cluster. We will use the Horizontal Pod Auto-scaler (HPA) to auto-scale the deployments based on CPU utilization, ensuring we can handle the load and provide a seamless user experience. Finally, we will restrict developer access using IAM controls.

### Step 1: Deployment and Service Setup
I have created two Kubernetes deployments, `users-api-deployment.yaml` and `shifts-api-deployment`. Each deployment has its own replica set with a desired replica count of 3. These deployments have their own Kubernetes services to expose the pods within the cluster. We will use the php:8.1.16 Docker image for both deployments.

Applying the Deployment and Service to the cluster:
```bash
kubectl apply -f users-api-deployment.yaml
kubectl apply -f users-api-svc.yaml
``` 
```bash
kubectl apply -f shifts-api-deployment.yaml
kubectl apply -f shifts-api-svc.yaml
```
Checking if the it was created successfully:
```bash
kubectl get pods
kubectl get service
```

### Step 2: Implementing Auto-scaling
To ensure that the deployment can handle high traffic, I will use the Kubernetes HPA to auto-scale the pods. I’ve set the target CPU utilization of 70% and we can use the default metrics server to monitor the CPU utilization. When the average CPU utilization exceeds the target threshold, the HPA will automatically scale the deployment to handle the additional load.
```bash
kubectl apply -f users-api-hpa.yaml
```
```bash
kubectl apply -f shifts-api-hpa.yaml.
```
This will create the Horizontal Pod Autoscalers for the `users-api` and `shifts-api` deployments and will automatically adjust the number of replicas based on the CPU utilization of the pods. 
For the bell-curve scaling during the day and low traffic during the night, we can create a cron job that adjusts the number of replicas of the deployment at different times of the day. We can use the Kubernetes `kubectl scale` command to set the number of replicas for the deployment based on the current time. 
The bash script that we can run as a cron job:
```bash
./cron-job-scaling.sh
```

### Step 3: Rolling Deployment and Rollback
We can use Kubernetes rolling deployments to ensure that we can deploy new versions of the container while minimizing downtime. Rolling deployments update the pods in a controlled manner, ensuring that the new version is gradually deployed while the old version is still running. If any issues arise during the deployment, we can roll back to the previous version. I have set the `revisionHistoryLimit` to 5. We can always change this.
To perform a rolling update for the deployments, we can use the `kubectl set image` command and to perform a rollback for the deployments, we can use `kubectl rollout undo` command.
Performing a rolling update for `users-api`:
```bash
kubectl set image deployment/users-api users-api=php:8.1.16-apache
```
Performing a rollback for `users-api`:
```bash
kubectl rollout undo deployment/users-api
```

### Step 4: IAM Controls

To restrict developer access to certain Kubernetes commands, we will implement IAM controls. I have used the Kubernetes RBAC (Role-Based Access Control) to create a role that only allows developers to deploy and roll back deployments.
In RBAC, I have created roles and role bindings to control access to Kubernetes resources. I have created a custom role with permissions to deploy and rollback deployments and limit access to certain commands or actions by denying permissions for those actions.
Here are the steps to set up RBAC:
Apply the service account `dev-team`:
```bash
kubectl apply -f dev-team.yaml
```
Apply the role `deployment-manager`:
```bash
Kubectl apply -f deployment-manager.yaml
```
Apply the roll binding `deployment-manager-binding`:
```bash
kubectl apply -f deployment-manager-binding.yaml
```
Apply the `restricted-role`:
```bash
kubectl apply -f restricted-role.yaml
```
Apply the `restricted-role-binding`:
```bash
kubectl apply -f restricted-role-binding.yaml
```
With this RBAC setup, the development team can deploy and rollback deployments, but they won't be able to perform actions such as deleting pods or modifying secrets.

### Bonus Questions
Applying Configs to Multiple Environments:
To apply the same configurations to multiple environments, we can use Kubernetes ConfigMaps and Secrets. We can create a ConfigMap and a Secret for each environment, each with its own set of values. We can then use Kubernetes templates to create different deployment files for each environment, replacing the specific values with the corresponding ConfigMap and Secret values.

Auto-scaling based on Network Latency:
To auto-scale the deployment based on network latency, we can use Kubernetes custom metrics. We can use a tool like Prometheus to monitor the network latency and expose it as a custom metric in Kubernetes. We can then create a custom HPA that uses this metric to auto-scale the deployment based on network latency rather than CPU utilization.

### Conclusion
This exercise required deploying two containers with independent APIs, implementing auto-scaling, rolling deployments, and IAM controls. By following the above steps, we can ensure that our deployment can handle high traffic, minimize downtime during deployments, and restrict developer access to the cluster. We can also use Kubernetes ConfigMaps and Secrets to apply the same configurations to multiple environments and use custom metrics for auto-scaling based on network latency.
