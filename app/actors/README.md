# Actors

Actors lets you move your application logic into into small composable service objects. It is a lightweight framework that helps you keep your models and controllers thin.

For usage explanation visit: https://github.com/sunny/actor#usage

# Rules

- Actors should be simple and should one thing (hint: single responsibility principle).
- When there are multiple things that should be orchestrated `play` should be used to compose them (more: https://github.com/sunny/actor#play-actors-in-a-sequence).
- Naming should be in the form of VerbNoun. For example RegisterUser, LoginUser, SendWelcomeEmail, etc.
- If there is some logical unit of domain it should be grouped into namespace. For example Project::InviteUser.
