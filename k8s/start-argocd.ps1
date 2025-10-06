# Script to start ArgoCD port forwarding
Write-Host "Starting ArgoCD port forwarding..." -ForegroundColor Green

# Stop any existing kubectl processes
Write-Host "Stopping existing kubectl processes..." -ForegroundColor Yellow
Get-Process kubectl -ErrorAction SilentlyContinue | Stop-Process -Force

# Start port forwarding
Write-Host "Starting port forward for ArgoCD server..." -ForegroundColor Green
Start-Process kubectl -ArgumentList "port-forward", "svc/argocd-server", "-n", "argocd", "8080:80"

# Wait a moment
Start-Sleep -Seconds 3

# Test connection
Write-Host "Testing ArgoCD connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri http://localhost:8080 -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ ArgoCD is running successfully!" -ForegroundColor Green
        Write-Host "🌐 ArgoCD UI: http://localhost:8080" -ForegroundColor Cyan
        Write-Host "👤 Username: admin" -ForegroundColor Cyan
        Write-Host "Password: HIdlVrbCE1USKQka" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ ArgoCD connection failed. Please check if ArgoCD is running." -ForegroundColor Red
    Write-Host "Try running: kubectl get pods -n argocd" -ForegroundColor Yellow
}
