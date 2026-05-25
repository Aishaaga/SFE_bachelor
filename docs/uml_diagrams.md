# Diagrammes UML - Projet SFE Biodiversité

## 1. Diagramme des Cas d'Utilisation (Use Case Diagram)

```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle

actor "Utilisateur" as User
actor "Administrateur" as Admin

rectangle "SFE Biodiversité" {
  usecase "S'authentifier" as UC1
  usecase "S'inscrire" as UC2
  usecase "Identifier une plante" as UC3
  usecase "Proposer une traduction" as UC4
  usecase "Voter pour une traduction" as UC5
  usecase "Partager une découverte" as UC6
  usecase "Voir le feed social" as UC7
  usecase "Consulter l'historique" as UC8
  usecase "Voir les cartes de distribution" as UC9
  usecase "Valider les traductions" as UC10
  usecase "Gérer les utilisateurs" as UC11
  usecase "Voir les statistiques" as UC12
  usecase "Recevoir des notifications" as UC13
}

User --> UC1
User --> UC2
User --> UC3
User --> UC4
User --> UC5
User --> UC6
User --> UC7
User --> UC8
User --> UC9
User --> UC13

Admin --> UC1
Admin --> UC10
Admin --> UC11
Admin --> UC12

UC3 --> UC4 : après identification
UC3 --> UC6 : optionnel
@enduml
```

## 2. Diagramme de Classes (Class Diagram)

```plantuml
@startuml
skinparam classAttributeIconSize 0

package "Frontend - Flutter" {
  class "Plant" as Plant {
    - String name
    - String scientificName
    - String family
    - String darijaName
    - String tamazightName
    - double confidence
    - String imageUrl
    + Plant()
  }

  class "TranslationSuggestion" as TranslationSuggestion {
    - String id
    - String scientificName
    - String darijaProposal
    - String tamazightProposal
    - String contributorName
    - String contributorEmail
    - String region
    - String notes
    - String status
    - DateTime submittedAt
    + TranslationSuggestion()
  }

  class "User" as UserFrontend {
    - String id
    - String email
    - String name
    - String region
    + User()
  }

  class "AuthService" as AuthService {
    + Future<bool> isLoggedIn()
    + Future<String?> getCurrentUserEmail()
    + Future<void> logout()
  }

  class "ProposalService" as ProposalService {
    + Future<void> saveProposal(TranslationSuggestion)
    + Future<List<TranslationSuggestion>> getAllProposals()
    + Future<List<TranslationSuggestion>> getProposalsByStatus()
  }
}

package "Backend - Node.js" {
  class "User" as UserBackend {
    - String _id
    - String email
    - String password
    - String name
    - String region
    - String role
    - DateTime createdAt
    + comparePassword()
    + generateToken()
  }

  class "Plant" as PlantBackend {
    - String _id
    - String name
    - String scientificName
    - String family
    - String localName
    - String arabicName
    - Boolean isMoroccanEndemic
    - String[] region
    - Number identificationCount
    - Number confidenceAvg
    - String source
  }

  class "TranslationSuggestion" as TranslationSuggestionBackend {
    - String _id
    - String scientificName
    - String darijaProposal
    - String tamazightProposal
    - String contributorName
    - String contributorEmail
    - String contributorRegion
    - String notes
    - String status
    - DateTime submittedAt
    - DateTime reviewedAt
    - String reviewedBy
    + approve()
    + reject()
    + requestReview()
  }

  class "FeedPost" as FeedPost {
    - String _id
    - String userId
    - String plantName
    - String scientificName
    - String imageUrl
    - String location
    - Number likesCount
    - Number commentsCount
    - DateTime createdAt
  }

  class "FeedComment" as FeedComment {
    - String _id
    - String postId
    - String userId
    - String content
    - DateTime createdAt
  }

  class "FeedLike" as FeedLike {
    - String _id
    - String postId
    - String userId
    - DateTime createdAt
  }

  class "Notification" as Notification {
    - String _id
    - String userId
    - String type
    - String title
    - String message
    - Boolean isRead
    - DateTime createdAt
  }

  class "Identification" as Identification {
    - String _id
    - String Identification
    - String plantName
    - String scientificName
    - String imageUrl
    - Number confidence
    - String location
    - DateTime createdAt
  }

  class "ApprovedTranslation" as ApprovedTranslation {
    - String _id
    - String scientificName
    - String darijaTranslation
    - String tamazightTranslation
    - String source
    - Number confidence
    - DateTime approvedAt
    - String approvedBy
  }

  class "TranslationVote" as TranslationVote {
    - String _id
    - String translationSuggestionId
    - String userId
    - Boolean isUpvote
    - DateTime createdAt
  }
}

PlantBackend "1" -- "*" Identification : a
UserBackend "1" -- "*" Identification : fait
UserBackend "1" -- "*" TranslationSuggestionBackend : propose
UserBackend "1" -- "*" FeedPost : publie
UserBackend "1" -- "*" FeedComment : commente
UserBackend "1" -- "*" FeedLike : aime
UserBackend "1" -- "*" TranslationVote : vote
UserBackend "1" -- "*" Notification : reçoit
FeedPost "1" -- "*" FeedComment : a
FeedPost "1" -- "*" FeedLike : a
TranslationSuggestionBackend "1" -- "*" TranslationVote : reçoit
@enduml
```

## 3. Diagramme de Séquence - Identification de Plante

```plantuml
@startuml
actor "Utilisateur" as User
participant "CameraScreen" as Camera
participant "PlantService" as PlantService
participant "Pl@ntNet API" as PlantNetAPI
participant "ResultScreen" as Result
participant "TranslationProposalScreen" as Proposal
participant "ProposalService" as ProposalService
participant "Backend API" as Backend

User -> Camera : Prend photo
Camera -> Camera : Compress image
Camera -> PlantService : identifyPlant(image)
PlantService -> PlantNetAPI : POST /identify
PlantNetAPI --> PlantService : JSON response (plant data)
PlantService --> Camera : Plant object
Camera -> Result : navigate with Plant & photo

Result -> Result : Display plant info
Result -> Result : Load translations

User -> Result : Click "Proposer traduction"
Result -> Proposal : navigate with Plant

Proposal -> Proposal : Display form
User -> Proposal : Fill translation form
Proposal -> ProposalService : saveProposal(suggestion)
ProposalService -> Backend : POST /api/translation-suggestions
Backend --> ProposalService : Success
ProposalService --> Proposal : Success
Proposal -> User : Show success dialog
@enduml
```

## 4. Diagramme de Séquence - Validation de Traduction

```plantuml
@startuml
actor "Administrateur" as Admin
participant "AdminProposalsScreen" as AdminScreen
participant "ProposalService" as ProposalService
participant "Backend API" as Backend
participant "Database" as DB
participant "NotificationService" as NotificationService

Admin -> AdminScreen : View proposals
AdminScreen -> ProposalService : getAllProposals()
ProposalService -> Backend : GET /api/translation-suggestions
Backend -> DB : Find all suggestions
DB --> Backend : Suggestions list
Backend --> ProposalService : Suggestions list
ProposalService --> AdminScreen : Display proposals

Admin -> AdminScreen : Select proposal
Admin -> AdminScreen : Click "Approuver"
AdminScreen -> ProposalService : approveProposal(id, notes)
ProposalService -> Backend : PUT /api/translation-suggestions/:id/approve
Backend -> DB : Update suggestion status
Backend -> DB : Create ApprovedTranslation
DB --> Backend : Success
Backend --> ProposalService : Success
ProposalService --> AdminScreen : Success

Backend -> NotificationService : Notify contributor
NotificationService -> NotificationService : Send notification
@enduml
```

## 5. Diagramme de Composants (Component Diagram)

```plantuml
@startuml
package "Application Mobile (Flutter)" {
  [CameraScreen] as Camera
  [ResultScreen] as Result
  [TranslationProposalScreen] as Proposal
  [AdminProposalsScreen] as Admin
  [SocialFeedScreen] as Feed
  [AuthService] as Auth
  [PlantService] as PlantSvc
  [ProposalService] as ProposalSvc
}

package "Backend API (Node.js/Express)" {
  [Auth Controller] as AuthCtrl
  [Plant Controller] as PlantCtrl
  [Translation Controller] as TransCtrl
  [Feed Controller] as FeedCtrl
  [Notification Controller] as NotifCtrl
  [Admin Controller] as AdminCtrl
}

package "Database (MongoDB)" {
  [User Collection] as Users
  [Plant Collection] as Plants
  [TranslationSuggestion Collection] as Suggestions
  [ApprovedTranslation Collection] as Approved
  [FeedPost Collection] as Posts
  [Notification Collection] as Notifs
}

package "External APIs" {
  [Pl@ntNet API] as PlantNet
  [GBIF API] as GBIF
}

Camera --> PlantSvc
Result --> PlantSvc
Proposal --> ProposalSvc
Admin --> ProposalSvc
Feed --> FeedCtrl

PlantSvc --> PlantCtrl
ProposalSvc --> TransCtrl
Auth --> AuthCtrl

AuthCtrl --> Users
PlantCtrl --> Plants
PlantCtrl --> PlantNet
TransCtrl --> Suggestions
TransCtrl --> Approved
FeedCtrl --> Posts
NotifCtrl --> Notifs
AdminCtrl --> Suggestions
AdminCtrl --> Approved

PlantCtrl --> GBIF
@enduml
```

## 6. Diagramme d'Activité - Soumission de Traduction

```plantuml
@startuml
start
:Utilisateur identifie une plante;
:Afficher écran de résultat;
if (Utilisateur veut proposer traduction?) then (non)
  :Retour à l'écran principal;
  stop
else (oui)
  :Naviguer vers écran de proposition;
  :Charger informations utilisateur;
  :Afficher formulaire de traduction;
  
  :Sélectionner langues (Darija/Tamazight);
  if (Darija sélectionné?) then (oui)
    :Saisir traduction Darija;
  endif
  if (Tamazight sélectionné?) then (oui)
    :Saisir traduction Tamazight;
  endif
  
  :Saisir région (optionnel);
  :Saisir notes (optionnel);
  
  :Cliquer sur "Soumettre";
  :Valider formulaire;
  if (Formulaire valide?) then (non)
    :Afficher erreurs;
    :Corriger erreurs;
  else (oui)
    :Vérifier connexion utilisateur;
    if (Utilisateur connecté?) then (non)
      :Afficher erreur de connexion;
      stop
    else (oui)
      :Créer objet TranslationSuggestion;
      :Envoyer au backend;
      if (Soumission réussie?) then (non)
        :Afficher erreur;
      else (oui)
        :Afficher dialogue de succès;
        :Vider cache traductions;
        :Retour à l'écran précédent;
      endif
    endif
  endif
endif
stop
@enduml
```

## 7. Diagramme de Déploiement (Deployment Diagram)

```plantuml
@startuml
cloud "Internet" {
  node "Mobile Device" {
    component "Flutter App" as App
  }
}

node "Server" {
  component "Node.js Backend" as Backend
  database "MongoDB" as DB
}

node "External Services" {
  component "Pl@ntNet API" as PlantNet
  component "GBIF API" as GBIF
}

App --> Backend : HTTPS/REST
Backend --> DB : Mongoose
Backend --> PlantNet : HTTP
Backend --> GBIF : HTTP
@enduml
```

## 8. Diagramme d'État - Suggestion de Traduction

```plantuml
@startuml
[*] --> Pending : Création

state Pending {
  [*] --> EnAttente
  EnAttente : En attente de validation
}

state Review {
  [*] --> NeedsReview
  NeedsReview : Nécessite révision
}

state Approved {
  [*] --> Approuvée
  Approuvée : Traduction validée
}

state Rejected {
  [*] --> Rejetée
  Rejetée : Traduction rejetée
}

Pending --> Review : Demande de révision
Pending --> Approved : Approuvé par admin
Pending --> Rejected : Rejeté par admin
Review --> Approved : Approuvé après révision
Review --> Rejected : Rejeté après révision
Approved --> [*]
Rejected --> [*]
@enduml
```

## 9. Diagramme de Séquence - Authentification

```plantuml
@startuml
actor "Utilisateur" as User
participant "LoginScreen" as Login
participant "AuthService" as Auth
participant "Backend API" as Backend
participant "Database" as DB

User -> Login : Enter email & password
User -> Login : Click "Connexion"
Login -> Auth : login(email, password)
Auth -> Backend : POST /api/auth/login
Backend -> DB : Find user by email
DB --> Backend : User document
Backend -> Backend : Compare password (bcrypt)
if (Password correct?) then (non)
  Backend --> Auth : Error (401)
  Auth --> Login : Error
  Login -> User : Show error message
else (oui)
  Backend -> Backend : Generate JWT token
  Backend --> Auth : Token + User data
  Auth -> Auth : Store token securely
  Auth --> Login : Success
  Login -> User : Navigate to Home
endif
@enduml
```

## 10. Diagramme de Packages - Architecture Frontend

```plantuml
@startuml
package "sfe_mobile" {
  package "lib" {
    package "screens" {
      [LoginScreen]
      [RegisterScreen]
      [HomeScreen]
      [CameraScreen]
      [ResultScreen]
      [TranslationProposalScreen]
      [AdminProposalsScreen]
      [SocialFeedScreen]
      [ProfileScreen]
      [HistoryScreen]
    }
    
    package "services" {
      [AuthService]
      [PlantService]
      [ProposalService]
      [FeedService]
      [NotificationService]
    }
    
    package "models" {
      [Plant]
      [TranslationSuggestion]
      [User]
      [FeedPost]
      [Notification]
    }
    
    package "widgets" {
      [PlantCard]
      [TranslationCard]
      [CustomButton]
    }
    
    package "data" {
      [PlantTranslations]
    }
    
    package "utils" {
      [ImageUtils]
      [LocationUtils]
    }
  }
}
@enduml
```

## 11. Diagramme de Séquence Simplifié - Identification de Plante (avec Pl@ntNet)

```plantuml
@startuml
actor "Utilisateur" as User
participant "Backend SFE" as Backend
participant "Pl@ntNet API" as PlantNet

User -> Backend : Envoie photo de plante
Backend -> Backend : Analyse et compression de l'image
Backend -> PlantNet : POST /identify (image)
PlantNet --> Backend : JSON response (nom scientifique, famille, confiance)
Backend -> Backend : Recherche traductions existantes
Backend --> User : Résultat (nom, traductions Darija/Tamazight)
@enduml
```

## 12. Diagramme de Séquence Simplifié - Recherche Données Scientifiques (avec GBIF)

```plantuml
@startuml
actor "Utilisateur" as User
participant "Backend SFE" as Backend
participant "GBIF API" as GBIF

User -> Backend : Demande informations scientifiques sur plante
Backend -> Backend : Vérifie cache local
if (Données en cache?) then (oui)
  Backend --> User : Retourne données du cache
else (non)
  Backend -> GBIF : GET /species (nom scientifique)
  GBIF --> Backend : JSON response (distribution, taxonomie)
  Backend -> Backend : Stocke dans cache
  Backend --> User : Retourne données GBIF
endif
@enduml
```

## 13. Diagramme de Séquence Simplifié - Soumission de Traduction

```plantuml
@startuml
actor "Utilisateur" as User
participant "Backend SFE" as Backend
database "MongoDB" as DB

User -> Backend : Soumet traduction (Darija/Tamazight)
Backend -> Backend : Valide formulaire
Backend -> DB : Enregistre TranslationSuggestion (status: pending)
DB --> Backend : Confirmation
Backend --> User : Message de succès (en attente de validation)
@enduml
```

## 14. Diagramme de Séquence Simplifié - Validation de Traduction

```plantuml
@startuml
actor "Administrateur" as Admin
participant "Backend SFE" as Backend
database "MongoDB" as DB
participant "Pl@ntNet API" as PlantNet
participant "GBIF API" as GBIF

Admin -> Backend : Consulte propositions en attente
Backend -> DB : GET TranslationSuggestion (status: pending)
DB --> Backend : Liste des propositions
Backend --> Admin : Affiche propositions

Admin -> Backend : Approuve/Rejette proposition
Backend -> PlantNet : Vérification nom scientifique (optionnel)
PlantNet --> Backend : Confirmation
Backend -> GBIF : Vérification distribution (optionnel)
GBIF --> Backend : Confirmation
Backend -> DB : UPDATE TranslationSuggestion (status: approved/rejected)
Backend -> DB : CREATE ApprovedTranslation (si approuvé)
DB --> Backend : Confirmation
Backend --> Admin : Confirmation de validation
@enduml
```

## 15. Diagramme de Séquence Simplifié - Workflow Complet Identification

```plantuml
@startuml
actor "Utilisateur" as User
participant "Backend SFE" as Backend
participant "Pl@ntNet API" as PlantNet
participant "GBIF API" as GBIF
database "MongoDB" as DB

User -> Backend : Prend photo de plante
Backend -> PlantNet : Identification via Pl@ntNet
PlantNet --> Backend : Résultat identification
Backend -> GBIF : Récupère données scientifiques
GBIF --> Backend : Données distribution/taxonomie
Backend -> DB : Enregistre identification
DB --> Backend : Confirmation
Backend -> DB : Recherche traductions existantes
DB --> Backend : Traductions Darija/Tamazight
Backend --> User : Résultat complet (identification + traductions)
User -> Backend : Propose nouvelle traduction (optionnel)
Backend -> DB : Enregistre proposition
DB --> Backend : Confirmation
Backend --> User : Proposition soumise
@enduml
```

## Instructions pour visualiser les diagrammes

Pour visualiser ces diagrammes PlantUML, vous pouvez:

1. **Utiliser un éditeur en ligne**: 
   - Aller sur https://plantuml.com/online
   - Copier-coller le code de chaque diagramme

2. **Utiliser VS Code**:
   - Installer l'extension "PlantUML"
   - Ouvrir un fichier .puml ou .md avec du code PlantUML
   - Prévisualiser avec Ctrl+D (ou Cmd+D sur Mac)

3. **Utiliser IntelliJ IDEA**:
   - Installer le plugin "PlantUML integration"
   - Ouvrir un fichier .puml
   - Clic droit -> "Show PlantUML Diagram"

4. **Générer des images**:
   ```bash
   # Installer PlantUML
   # Télécharger depuis https://plantuml.com/download
   java -jar plantuml.jar diagramme.puml
   ```
