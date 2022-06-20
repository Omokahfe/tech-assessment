# EKS Cluster Setup

This project creates an EKS cluster with two worker nodes, it also creates a simple kubernetes app deployed on the cluster.

## Tools Used
1. **Terraform:** This is an open source tool, it aids automation of infrastructure on any cloud platform [...](https://www.terraform.io/)

2. **Terragrunt:** This is a wrapper over `Terraform`, it keeps your configuration `DRY`. It helps to manage multiple modules, configuration for multiple environment, with many more features [...](https://terragrunt.gruntwork.io/)

3. **Kubernetes:** is an open-source system for automating deployment, scaling, and management of containerised applications [...](https://kubernetes.io/)

4. **Github Actions:** This is a tool to automate, customise, and execute your software development workflows right in your `Github` repository [...](https://docs.github.com/en/actions)

5. **Amazon Web Service:** This is the cloud platform where our infrastructure would run on. It's one of the household names 😉 [...](https://aws.amazon.com/)

## Setup Process
In this project, terraform was used to create the EKS cluster on AWS. The cluster has two worker nodes running on it. The `instance type` of the worker node is `t2.micro`, one node is quite small to house the number of resources we planned to provision on the cluster, that's the reason I used 2 worker nodes.

EKS and VPC modules were used in the provisioning of the cluster. Modules have collection of standard configuration, reducing the amount of code one have to develop for similar infrastructure components. I referenced the needed modules and personalised some attributes, based on the need for this project. 

Looking at the possibility of deploying same infrastructure to multiple environments but with environment specific values, `terragrunt` came handy. The common configuration for all environment is embedded in `terragrunt/terragrunt.hcl`, I created an environment specific folder in the `terragrunt` folder, like `dev`, to house the config for the environment. In `dev` folder, I have component specific folder also, like `eks`, should there be a need for more component in this infrastructure.

The deployment file of the `hello-world` application using the image `paulbouwer/hello-kubernetes` in the `development` namespace can be seen in `resources/app.yaml` file.

I used `Github Actions` for the deployment of the infrastructure, it's easy to use. I Created workflows for specific needs, this would help avoid mistakes while provisioning the infrastructure.

To choose the right `Actions` in workflow, use [Marketplace](https://github.com/marketplace), you can see how to use any action there.


The `infra-plan` job is executed when there is a push to the `test` branch, you can choose a branch of your choice. This job has steps, each step has a task to perform. One of the steps is used for authentication to `AWS`, the credentials are stored on the project as secrets, masked and useable only with the project. See sample

```
aws-access-key-id: ${{ secrets.AWS_KEY_ID }}
aws-secret-access-key: ${{ secrets.AWS_SECRETE_ID }}
aws-region: 'eu-west-1'
```

The jobs in other workflows can only be triggered manually using `workflow_dispatch`. This can be triggered on the `master` branch due to the peculiarity of the tasks.

To test the creation of the infrastructure locally;
1. setup `AWS CLI` on your local machine, add your access key and secret key, [see more](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. go to `terragrunt/dev/eks/` run the command `terragrunt init`. This downloads the code for all your modules into `.terraform/modules`
3. run `terragrunt plan`, this returns a detailed output of all the changes the configuration will have on your platform, either to be added, changed or destroyed.
4. if the output from `3` is what you expected, run `terragrunt apply`, this applies the output from `3` on your platform.
5. if there is no error from `4`, you need to add the eks config of the newly created EKS cluster to your local machine, use `aws eks update-kubeconfig --name [cluster-name] --region eu-west-1`.
6. go to the folder `resources`, run `kubectl apply -f app.yaml`, this creates the namespace `development` and pod `hello-app`, running the image `paulbouwer/hello-kubernetes`.
7. check the state of the pod, use `kubectl get pods -n development`, the output should look like

```
NAMESPACE     NAME                         READY   STATUS    RESTARTS   AGE
development   hello-app-67f67f8f8d-cs22t   1/1     Running   0          15s
```

8. check logs of the pod, use `kubectl -n development logs hello-app-67f67f8f8d-cs22t`, the output should look like

```
npm info it worked if it ends with ok
npm info using npm@5.0.3
npm info using node@v8.1.0
npm info lifecycle hello-kubernetes@1.5.0~prestart: hello-kubernetes@1.5.0
npm info lifecycle hello-kubernetes@1.5.0~start: hello-kubernetes@1.5.0

> hello-kubernetes@1.5.0 start /usr/src/app
> node server.js

Listening on: http://hello-app-67f67f8f8d-cs22t:8080
```

9. To check the events on the pod, use `kubectl -n development describe po hello-app-67f67f8f8d-cs22t`. Go to the later part of the output, you should see

```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  3m43s  default-scheduler  Successfully assigned development/hello-app-67f67f8f8d-cs22t to ip-10-0-1-145.eu-west-1.compute.internal
  Normal  Pulling    3m42s  kubelet            Pulling image "paulbouwer/hello-kubernetes:1.5"
  Normal  Pulled     3m37s  kubelet            Successfully pulled image "paulbouwer/hello-kubernetes:1.5" in 5.362912821s
  Normal  Created    3m37s  kubelet            Created container hello-app
  Normal  Started    3m37s  kubelet            Started container hello-app
```

10. to increase the number of pods in the deployment, use `kubectl scale --replicas=3 deployments.apps/hello-app -n development`, the response you get is `deployment.apps/hello-app scaled`. Then you can check the state of the new pods using `kubectl get pods -n development`

11. access the running application locally using port-forwarding, run `kubectl -n development port-forward hello-app-67f67f8f8d-cs22t 8080:8080`, then you can access the application using `http://localhost:8080/` on your browser.

Should you need more imperatives commands to check your application, [see here](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands).

## NOTE
Kindly destroy the infrastructure to avoid incurring cost when you are not using the resources. Select the `Infra-Delete` workflow in `Github Actions`, manually trigger the workflow, it will run the job to delete the infrastructure.