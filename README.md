# Django CMS CI/CD với ArgoCD và Helm

Repository này chứa cấu hình Kubernetes và Helm chart để deploy Django CMS application sử dụng ArgoCD.

## Cấu trúc Repository

```
├── k8s/                       # Kubernetes manifests
│   ├── argocd-namespace.yaml  # Namespace definitions
│   ├── argocd-install.yaml    # ArgoCD installation
│   ├── argocd-application.yaml # ArgoCD Application manifest
│   ├── run-argocd.ps1         # Script chạy ArgoCD
│   └── cleanup.ps1            # Script cleanup
├── helm/cms-app/              # Helm chart
│   ├── Chart.yaml            # Helm chart metadata
│   ├── values.yaml           # Default values
│   └── templates/            # Kubernetes templates
│       ├── deployment.yaml   # Django deployment
│       ├── service.yaml      # Service definition
│       ├── ingress.yaml      # Ingress configuration
│       ├── postgres.yaml     # PostgreSQL deployment
│       ├── secret.yaml       # Secrets
│       └── serviceaccount.yaml
└── README.md
```

## Yêu cầu

- Kubernetes cluster
- kubectl configured
- Helm (optional, ArgoCD sẽ handle)

## Cài đặt và Sử dụng

### 1. Chạy ArgoCD và Deploy Application

```powershell
# Chạy script để cài đặt ArgoCD và deploy application
cd k8s
.\run-argocd.ps1
```

### 2. Cleanup (nếu cần)

```powershell
# Xóa tất cả resources
cd k8s
.\cleanup.ps1
```

### 3. Truy cập Application

- ArgoCD UI: https://localhost:8080
- Django CMS API: http://cms-api.local (cần cấu hình hosts file)

## Cấu hình

### ArgoCD Application

Application được cấu hình để:
- Sử dụng repository: `https://github.com/QuanMBL/Project_cms_ci-cd_FPT_repoA.git`
- Deploy từ Helm chart trong `helm/cms-app`
- Auto-sync enabled
- Namespace: `cms-app`

### Helm Chart

Helm chart bao gồm:
- Django application deployment
- PostgreSQL database
- Service và Ingress
- Secrets và ConfigMaps
- ServiceAccount

### Image

Application sử dụng image từ GitHub Container Registry:
- Repository: `ghcr.io/quanmbl/project_cms_ci-cd_fpt_repoa`
- Tag: `latest` (auto-updated bởi ArgoCD Image Updater)

## Environment Variables

- `SECRET_KEY`: Django secret key
- `DEBUG`: Debug mode (false in production)
- `ALLOWED_HOSTS`: Allowed hosts
- `DATABASE_URL`: PostgreSQL connection string
- `CORS_ALLOW_ALL_ORIGINS`: CORS configuration
- `LANGUAGE_CODE`: Language (vi)
- `TIME_ZONE`: Timezone (Asia/Ho_Chi_Minh)

## Database

- PostgreSQL 15
- Persistent volume
- Database: `cms_db`
- User: `cms_user`
- Password: `cms_password`

## Monitoring

Để kiểm tra trạng thái:

```powershell
# Kiểm tra ArgoCD applications
kubectl get applications -n argocd

# Kiểm tra pods
kubectl get pods -n cms-app

# Kiểm tra services
kubectl get svc -n cms-app

# Kiểm tra logs
kubectl logs -f deployment/cms-app -n cms-app
```

## Troubleshooting

### ArgoCD không sync được
```powershell
# Kiểm tra ArgoCD logs
kubectl logs -f deployment/argocd-server -n argocd

# Force sync
kubectl patch application cms-app -n argocd --type merge -p '{"operation":{"sync":{"syncStrategy":{"force":true}}}}'
```

### Application không start được
```powershell
# Kiểm tra pod logs
kubectl logs -f deployment/cms-app -n cms-app

# Kiểm tra events
kubectl get events -n cms-app
```

## Cleanup

```powershell
# Xóa application
kubectl delete application cms-app -n argocd

# Xóa namespace
kubectl delete namespace cms-app

# Xóa ArgoCD
kubectl delete namespace argocd
```