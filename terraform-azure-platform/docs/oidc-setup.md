# OIDC Setup Guide
1. Create Azure App Registration.
2. Add federated credentials for GitHub repo/environment (DEV/UAT/PROD).
3. Grant RBAC: Contributor on scoped RG, Storage Blob Data Contributor on backend state account, Resource Policy Contributor for governance assignments.
4. Add environment variables: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.
