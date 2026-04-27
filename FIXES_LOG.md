# Journal des Corrections

## Format : [Date] - [Branche] - [Description]

### 2026-04-27 - main - Authentification token
- **Problème** : "Accès non autorisé. Token manquant"
- **Solution** : Ajout de `_getHeaders()` dans `saveProposal()`
- **Fichiers** : 
  - `frontend/lib/services/proposal_service.dart`
  - `backend/routes/translation-suggestions.js`
- **Merge vers** : feature/admin_dashboard

---

## Règles à suivre :
1. Une seule branche de correction
2. Documenter ici immédiatement
3. Merger vers autres branches
4. Jamais de corrections parallèles
