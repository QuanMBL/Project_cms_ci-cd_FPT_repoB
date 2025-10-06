# Script to cleanup ArgoCD and CMS application
Write-Host "Cleaning up ArgoCD and CMS application..." -ForegroundColor Red

# Stop port forwarding
Write-Host "Stopping port forwarding..." -ForegroundColor Yellow
Get-Process kubectl -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -like "*port-forward*"} | Stop-Process -Force

# Delete application
Write-Host "Deleting CMS application..." -ForegroundColor Yellow
kubectl delete application cms-app -n argocd --ignore-not-found=true

# Delete namespaces
Write-Host "Deleting namespaces..." -ForegroundColor Yellow
kubectl delete namespace cms-app --ignore-not-found=true
kubectl delete namespace argocd --ignore-not-found=true

Write-Host "Cleanup completed!" -ForegroundColor Green
