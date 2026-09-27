---
title: "Kubernetes学习路径与实用工具箱：从架构到可跑的样例"
date: 2025-12-15T08:00:00+08:00
tags: [ "k8s", "devops", "容器" ]
description: "K8s 入门到实用：架构与核心资源对象速览、可直接 apply 的 Deployment+Service+Ingress 样例、kubectl 高频命令、k9s/Lens/stern/helm/kubectx 等工具箱选型"
categories: [ "devops" ]
toc: true
---

## 前言

k8s 概念多，刚上手容易懵。其实核心就两件事：把容器跑起来，让别人访问到。这篇整理一条最短的学习路径，再把自己用下来觉得顺手的工具列一下，工具装对了能少走很多弯路。

## 1、架构

控制平面管「应该是什么样」，节点负责「实际是什么样」：

```
控制平面（Control Plane）                     工作节点（Node x N）
├── kube-apiserver    ← 一切操作的入口         ├── kubelet        ← 管本机容器生命周期
├── etcd              ← 集群的数据库           ├── kube-proxy     ← 管 Service 转发
├── kube-scheduler    ← 决定 Pod 落在哪个节点   └── 容器运行时      ← containerd
└── kube-controller-manager ← 维持期望状态
```

用 k8s 做的所有操作，本质都是告诉 apiserver 一个期望状态，然后控制器发现差距、往那个方向收敛。理解了这个，Deployment、ReplicaSet、HPA 就都好懂了。

## 2、核心资源对象

按功能记四组：

| 分组 | 对象 | 用途 |
| - | - | - |
| 工作负载 | Pod / Deployment / StatefulSet / DaemonSet / Job | Pod 是最小单元；Deployment 管无状态多副本；StatefulSet 管有序有状态（mysql）；DaemonSet 每节点跑一个（日志 agent）；Job 管一次性任务 |
| 网络 | Service / Ingress | Service 是 Pod 的虚拟 IP + 负载均衡；Ingress 是七层入口（域名/路径路由） |
| 配置 | ConfigMap / Secret | 配置和镜像解耦；Secret 存敏感信息（base64 编码，不是加密） |
| 存储 | PV / PVC / StorageClass | 持久卷和申请解耦，Pod 删了数据还在 |

## 3、一套能跑的样例

**deployment.yaml**：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-web
  labels: { app: demo-web }
spec:
  replicas: 2                       # 期望 2 副本
  selector:
    matchLabels: { app: demo-web }  # 必须能匹配 template 里的 labels
  template:
    metadata:
      labels: { app: demo-web }
    spec:
      containers:
        - name: web
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
          resources:                # 不写 requests 的 Pod 调度质量差
            requests: { cpu: 100m, memory: 128Mi }
            limits:   { cpu: 500m, memory: 256Mi }
          livenessProbe:            # 存活探针：失败就重启容器
            httpGet: { path: /, port: 80 }
            initialDelaySeconds: 5
            periodSeconds: 10
          readinessProbe:           # 就绪探针：失败就从 Service 摘除流量
            httpGet: { path: /, port: 80 }
            initialDelaySeconds: 3
```

**service.yaml**：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-web-svc
spec:
  type: ClusterIP                  # 集群内访问；对外用 NodePort/LoadBalancer
  selector: { app: demo-web }      # 按标签选中上面 2 个 Pod
  ports:
    - port: 80
      targetPort: 80
```

**ingress.yaml**（要集群先装好 ingress-nginx 控制器）：

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-web-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: demo.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: demo-web-svc
                port: { number: 80 }
```

```bash
kubectl apply -f deployment.yaml -f service.yaml -f ingress.yaml
kubectl get pods,svc,ingress -o wide
```

本地没有集群的话，kind 或者 minikube 十分钟能搭一个：

```bash
brew install kind && kind create cluster --name learn
```

## 4、kubectl 高频命令

```bash
# 查（-o wide 显示 IP/节点；-A 全命名空间）
kubectl get pods -o wide
kubectl describe pod demo-web-xxxx        # 排查第一步：看 Events 段
kubectl logs -f demo-web-xxxx --tail=100  # 看日志（-p 看崩溃前那次）
kubectl exec -it demo-web-xxxx -- sh      # 进容器

# 改
kubectl apply -f xx.yaml                  # 声明式，推荐
kubectl set image deploy/demo-web web=nginx:1.29   # 改镜像就会触发滚动升级
kubectl rollout undo deploy/demo-web      # 一键回滚
kubectl scale deploy/demo-web --replicas=5

# 排障
kubectl get events --sort-by=.lastTimestamp | tail
kubectl top pods                          # 资源占用（要先装 metrics-server）
```

## 5、实用工具

这几个都是自己用过之后留下的：

| 工具 | 类型 | 解决什么 | 使用感受 |
| - | - | - | - |
| **k9s** | 终端 UI | 把 kubectl 变成交互式界面：`:pods` 看 Pod、`:logs` 追日志、`d` describe、`y` 编辑 | 强烈推荐，学习期和日常运维都省很多事 |
| **Lens / OpenLens** | 桌面工具 | 多集群图形化管理，内置终端/日志/资源图 | 看资源图方便；OpenLens 是开源内核版 |
| **stern** | 日志 | `stern demo-web` 一次 tail 多个 Pod 的日志 | kubectl logs 一次只能看一个，滚动升级追日志全靠它 |
| **kubectx / kubens** | 切换器 | `kubectx prod` 切集群、`kubens demo` 切命名空间 | 多集群多环境必备 |
| **helm** | 包管理 | `helm install ingress-nginx ingress-nginx/ingress-nginx` 一条命令装组件 | 装中间件的事实标准 |
| **kustomize** | 配置分层 | base + overlay 按 environment 叠差异化配置 | kubectl 内置（`apply -k`），dev/prod 差异就用它 |
| **kind / minikube** | 本地集群 | 笔记本上起个学习集群 | kind 更适合 CI；minikube 功能全 |

装上 k9s 和补全，体验立刻不一样：

```bash
brew install k9s kubectx stern
echo "source <(kubectl completion bash)" >> ~/.bashrc   # 命令补全
alias k=kubectl
```

## 6、学习路径

1. 第一周：本地 kind 起集群，把第三节的 yaml 手敲 apply 一遍，get/describe/logs/exec 用熟
2. 第二周：装 k9s，用它把上一周的操作重做一遍；玩 Deployment 的滚动升级和回滚（`set image` → `rollout status` → `undo`）
3. 第三周：ConfigMap/Secret 挂载、健康探针、requests/limits 对调度的影响；用 helm 装一个 ingress-nginx 和 redis
4. 之后：StatefulSet 跑有状态、HPA 自动扩缩容、NetworkPolicy、kustomize 管 dev/prod 差异，按需深入

## 总结

把第三节的样例亲手跑通一遍，工具装上 k9s + stern + kubectx，k8s 入门就没那么难了。剩下的就是遇到什么查什么，用着用着就熟了。

## 相关阅读

- [GraalVM与Native Image详解](/post/2025-09-18-graalvm-native-image/)（容器化编译/运行镜像选型）
- [docker镜像清单与梳理](/post/2026-09-10-docker_images/)
