
# Project Title

A brief description of what this project does and who it's for


## Documentation

[Documentation](https://linktodocumentation)


## Installation

Install my-project with npm

```bash
  npm install my-project
  cd my-project
```
    
## Usage/Examples

```javascript
import Component from 'my-project'

function App() {
  return <Component />
}
```


## API Reference

#### Create User
```http
  POST /users
```


| Parameter  | Type     | Description                                  |
|:-----------|:---------|:---------------------------------------------|
| `username` | `string` | **Required**. The username of the user.      |
| `password` | `string` | **Required**. The password for the account.  |
| `email`    | `string` | **Required**. The email address of the user. |

#### List Users
```http
  GET /users
```

#### Get User by ID
```http
  GET /users/{userId}
```

| Parameter | Type            | Description                                |
|:----------|:----------------|:-------------------------------------------|
| `userId`  | `string` (UUID) | **Required**. The ID of the user to fetch. |

#### Update User
```http
  PUT /users/{userId}
```

| Parameter | Type            | Description                                 |
|:----------|:----------------|:--------------------------------------------|
| `userId`  | `string` (UUID) | **Required**. The ID of the user to update. |
#### Delete User
```http
  DELETE /users/{userId}
```

| Parameter | Type            | Description                                 |
|:----------|:----------------|:--------------------------------------------|
| `userId`  | `string` (UUID) | **Required**. The ID of the user to delete. |

#### User Authentication
```http
  POST /auth/login
```

| Parameter  | Type     | Description                             |
|:-----------|:---------|:----------------------------------------|
| `username` | `string` | **Required**. The username of the user. |
| `password` | `string` | **Required**. The password of the user. |

#### User Logout
```http
  POST /auth/logout
```

#### Change Password
```http
  PUT /users/{userId}/changepassword
```

| Parameter     | Type            | Description                       |
|:--------------|:----------------|:----------------------------------|
| `userId`      | `string` (UUID) | **Required**. The ID of the user. |
| `newPassword` | `string`        | **Required**. The new password.   |

#### Reset Password
```http
  POST /users/resetpassword
```

| Parameter | Type     | Description                                                        |
|:----------|:---------|:-------------------------------------------------------------------|
| `email`   | `string` | **Required**. The email address of the user to reset the password. |

#### add(num1, num2)

Takes two numbers and returns the sum.


## Deployment

To deploy this project run

```bash
  npm run deploy
```


## Run Locally

Clone the project

```bash
  git clone https://link-to-project
```

Go to the project directory

```bash
  cd my-project
```

Install dependencies

```bash
  npm install
```

Start the server

```bash
  npm run start
```


## Running Tests

To run tests, run the following command

```bash
  npm run test
```


## Lessons Learned

What did you learn while building this project? What challenges did you face and how did you overcome them?

