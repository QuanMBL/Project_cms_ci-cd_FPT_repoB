# Kubernetes Manifests và Helm Charts

Repository này chứa các manifest Kubernetes và Helm charts để deploy Django CMS API.

## Cấu trúc

```
├── namespace.yaml              # Namespace cho ứng dụng
├── configmap.yaml             # ConfigMap cho Django settings
├── secret.yaml                # Secret cho sensitive data
├── postgres-deployment.yaml    # PostgreSQL deployment
├── django-deployment.yaml     # Django app deployment
├── ingress.yaml               # Ingress configuration
└── helm/
    └── cms-app/               # Helm chart
        ├── Chart.yaml         # Chart metadata
        ├── values.yaml        # Default values
        └── templates/      # Kubernetes templates
            ├── deployment.yaml
            ├── service.yaml
            ├── ingress.yaml
            ├── secret.yaml
            ├── serviceaccount.yaml
            ├── postgres.yaml
            └── _helpers.tpl
```

## Deploy với kubectl

### 1. Tạo namespace
```bash
kubectl apply -f namespace.yaml
```

### 2. Deploy PostgreSQL
```bash
kubectl apply -f postgres-deployment.yaml
```

### 3. Deploy Django app
```bash
kubectl apply -f django-deployment.yaml
```

### 4. Cấu hình Ingress
```bash
kubectl apply -f ingress.yaml
```

## Deploy với Helm

### 1. Cài đặt Helm chart
```bash
helm install cms-app ./helm/cms-app --namespace cms-app --create-namespace
```

### 2. Upgrade deployment
```bash
helm upgrade cms-app ./helm/cms-app --namespace cms-app
```

### 3. Uninstall
```bash
helm uninstall cms-app --namespace cms-app
```

## Cấu hình

### Environment Variables

- `SECRET_KEY`: Django secret key
- `DEBUG`: Debug mode (True/False)
- `ALLOWED_HOSTS`: Allowed hosts
- `CORS_ALLOW_ALL_ORIGINS`: CORS settings
- `LANGUAGE_CODE`: Language code (vi)
- `TIME_ZONE`: Time zone (Asia/Ho_Chi_Minh)

### Database

- PostgreSQL 15
- Persistent storage: 10Gi
- User: cms_user
- Database: cms_db

### Resources

- **Django App:**
  - CPU: 250m (request) / 500m (limit)
  - Memory: 256Mi (request) / 512Mi (limit)
  - Replicas: 3

- **PostgreSQL:**
  - CPU: 250m (request) / 500m (limit)
  - Memory: 256Mi (request) / 512Mi (limit)
  - Replicas: 1

## Health Checks

- **Liveness Probe:** `/api/health/` (30s initial delay, 10s period)
- **Readiness Probe:** `/api/health/` (5s initial delay, 5s period)

## Ingress

- **Host:** cms-api.local
- **Path:** /
- **Annotations:**
  - CORS enabled
  - SSL redirect disabled
  - Regex matching enabled

## CI/CD

Repository này được cấu hình với GitHub Actions để:
- Deploy tự động khi push vào main branch
- Sử dụng Helm để deploy
- Verify deployment sau khi deploy
- Health check để đảm bảo ứng dụng hoạt động

## Secrets

Cần tạo các secrets sau:

```bash
# Django secret key
kubectl create secret generic django-secret \
  --from-literal=SECRET_KEY=your-secret-key-here \
  --namespace cms-app

# Database credentials
kubectl create secret generic django-secret \
  --from-literal=DB_NAME=cms_db \
  --from-literal=DB_USER=cms_user \
  --from-literal=DB_PASSWORD=cms_password \
  --from-literal=DB_HOST=cms-postgres \
  --from-literal=DB_PORT=5432 \
  --namespace cms-app
```

## Troubleshooting

### Kiểm tra pods
```bash
kubectl get pods -n cms-app
kubectl describe pod <pod-name> -n cms-app
kubectl logs <pod-name> -n cms-app
```

### Kiểm tra services
```bash
kubectl get services -n cms-app
kubectl describe service <service-name> -n cms-app
```

### Kiểm tra ingress
```bash
kubectl get ingress -n cms-app
kubectl describe ingress <ingress-name> -n cms-app
```

### Port forward để test local
```bash
kubectl port-forward service/django-cms-service 8000:8000 -n cms-app
```
