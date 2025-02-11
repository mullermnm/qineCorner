# Articles API Documentation

## Base URL
`/api/articles`

## Models

### Article
```json
{
  "id": "string",
  "title": "string",
  "content": "string",
  "author": {
    "id": "string",
    "name": "string",
    "avatar": "string",
    "email": "string"
  },
  "tags": ["string"],
  "media": [
    {
      "id": "string",
      "url": "string",
      "type": "string",
      "thumbnailUrl": "string (optional)"
    }
  ],
  "status": "draft | published | deleted",
  "views": "number",
  "likes": "number",
  "comments": "number",
  "shares": "number",
  "createdAt": "ISO date string",
  "updatedAt": "ISO date string"
}
```

## Endpoints

### GET /articles
Get a list of articles with optional filters.

Query Parameters:
- `category`: (optional) Filter by category
- `authorId`: (optional) Filter by author ID
- `status`: (optional) Filter by status (draft/published/deleted)

Response:
```json
{
  "articles": [Article],
  "total": "number",
  "page": "number",
  "perPage": "number"
}
```

### GET /articles/featured
Get a list of featured articles.

Response:
```json
{
  "articles": [Article]
}
```

### GET /articles/:id
Get detailed information about a specific article.

Response:
```json
{
  "article": Article
}
```

### POST /articles
Create a new article.

Request Body:
```json
{
  "title": "string (required)",
  "content": "string (required)",
  "tags": ["string"] (required),
  "media": [
    {
      "url": "string",
      "type": "string"
    }
  ],
  "status": "draft | published"
}
```

Response:
```json
{
  "article": Article
}
```

### PUT /articles/:id
Update an existing article.

Request Body: (all fields optional)
```json
{
  "title": "string",
  "content": "string",
  "tags": ["string"],
  "media": [
    {
      "url": "string",
      "type": "string"
    }
  ]
}
```

Response:
```json
{
  "article": Article
}
```

### DELETE /articles/:id
Delete an article (marks as deleted).

### POST /articles/media
Upload media file for an article.

Request:
- Content-Type: multipart/form-data
- Body: file (required)

Response:
```json
{
  "url": "string"
}
```

### POST /articles/:id/publish
Publish a draft article.

Response:
```json
{
  "article": Article
}
```

### POST /articles/:id/draft
Move a published article back to drafts.

Response:
```json
{
  "article": Article
}
```

### POST /articles/:id/like
Like an article.

### DELETE /articles/:id/like
Unlike an article.

### POST /articles/:id/save
Save an article.

### DELETE /articles/:id/save
Unsave an article.

### POST /articles/:id/share
Record a share of an article.

### POST /articles/:id/view
Record a view of an article.

## Error Responses

All endpoints may return the following errors:

```json
{
  "error": {
    "code": "string",
    "message": "string",
    "details": {} (optional)
  }
}
```

Common Error Codes:
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 422: Validation Error
- 500: Internal Server Error

## Authentication

All endpoints except GET /articles and GET /articles/:id require authentication.
Send the JWT token in the Authorization header:

```
Authorization: Bearer <token>
```
