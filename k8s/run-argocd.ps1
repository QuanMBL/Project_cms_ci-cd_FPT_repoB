# Script to run ArgoCD and deploy CMS application
Write-Host "Starting ArgoCD deployment..." -ForegroundColor Green

# Step 1: Create namespaces
Write-Host "Creating namespaces..." -ForegroundColor Yellow
kubectl apply -f argocd-namespace.yaml

# Step 2: Install ArgoCD
Write-Host "Installing ArgoCD..." -ForegroundColor Yellow
kubectl apply -f argocd-install.yaml

# Step 3: Wait for ArgoCD to be ready
Write-Host "Waiting for ArgoCD to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Step 4: Get ArgoCD admin password
Write-Host "Getting ArgoCD admin password..." -ForegroundColor Cyan
$password = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>$null
if ($password) {
    $decodedPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($password))
    Write-Host "ArgoCD Admin Password: $decodedPassword" -ForegroundColor Green
} else {
    Write-Host "Creating initial admin secret..." -ForegroundColor Yellow
    kubectl -n argocd create secret generic argocd-initial-admin-secret --from-literal=password=admin123
    Write-Host "ArgoCD Admin Password: admin123" -ForegroundColor Green
}

# Step 5: Port forward ArgoCD server
Write-Host "Starting port forward for ArgoCD server..." -ForegroundColor Green
Start-Process kubectl -ArgumentList "port-forward", "svc/argocd-server", "-n", "argocd", "8080:80"

# Step 6: Deploy CMS Application
Write-Host "Deploying CMS Application..." -ForegroundColor Yellow
kubectl apply -f argocd-application.yaml

# Step 7: Wait for application to be synced
Write-Host "Waiting for application to be synced..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Step 8: Get application status
Write-Host "Application Status:" -ForegroundColor Cyan
kubectl get application cms-app -n argocd

# Step 9: Get pods status
Write-Host "Pods Status:" -ForegroundColor Cyan
kubectl get pods -n cms-app

# Step 10: Get services
Write-Host "Services:" -ForegroundColor Cyan
kubectl get svc -n cms-app

Write-Host "`nArgoCD is now available at: https://localhost:8080" -ForegroundColor Green
Write-Host "Username: admin" -ForegroundColor Green
Write-Host "Password: $decodedPassword" -ForegroundColor Green
Write-Host "`nDeployment completed!" -ForegroundColor Green
