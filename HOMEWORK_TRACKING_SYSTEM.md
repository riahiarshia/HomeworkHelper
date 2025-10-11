# Homework Tracking System

## Overview
The Homework Tracking System provides comprehensive analytics for homework submissions, tracking every assignment uploaded by users even if they delete it from their local app. This enables admin analytics and user progress monitoring.

## Database Schema

### Users Table Update
```sql
ALTER TABLE users 
ADD COLUMN total_homework_submissions INTEGER DEFAULT 0;
```
- **total_homework_submissions**: Running counter that increments with each submission, never decrements

### Homework Submissions Table
```sql
CREATE TABLE homework_submissions (
    submission_id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    problem_id VARCHAR(255),
    subject VARCHAR(100),
    problem_text TEXT,
    image_filename VARCHAR(255),
    total_steps INTEGER DEFAULT 0,
    completed_steps INTEGER DEFAULT 0,
    skipped_steps INTEGER DEFAULT 0,
    status VARCHAR(50),
    submitted_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    time_spent_seconds INTEGER,
    hints_used INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

**Key Features:**
- Permanent record of all submissions
- Tracks completion status and time
- Records hints used and steps completed
- Survives user deletion of problems from app

## API Endpoints

### User Endpoints

#### POST /api/homework/submit
Track a new homework submission.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "problemId": "uuid",
  "subject": "Math",
  "problemText": "Solve for x",
  "imageFilename": "image.jpg",
  "totalSteps": 5,
  "completedSteps": 0,
  "skippedSteps": 0,
  "status": "submitted",
  "timeSpentSeconds": 0,
  "hintsUsed": 0
}
```

**Response:**
```json
{
  "success": true,
  "submissionId": "uuid",
  "submittedAt": "2025-10-11T12:00:00Z",
  "totalSubmissions": 15,
  "message": "Homework submission tracked successfully"
}
```

#### PUT /api/homework/complete/:problemId
Update homework completion status.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "completedSteps": 5,
  "skippedSteps": 0,
  "status": "completed",
  "timeSpentSeconds": 300,
  "hintsUsed": 2
}
```

**Response:**
```json
{
  "success": true,
  "submissionId": "uuid",
  "message": "Homework completion updated successfully"
}
```

#### GET /api/homework/stats
Get current user's homework statistics.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "stats": {
    "totalSubmissions": 15,
    "detailedSubmissionCount": 15,
    "completedCount": 12,
    "inProgressCount": 3,
    "avgTimeSeconds": 250,
    "avgHintsUsed": 2,
    "bySubject": [
      {
        "subject": "Math",
        "count": 10,
        "avg_completed_steps": 4.5,
        "avg_time_seconds": 300
      }
    ],
    "recentSubmissions": [...]
  }
}
```

### Admin Endpoints

#### GET /api/homework/admin/submissions
Get all homework submissions with filtering.

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Query Parameters:**
- `userId` (optional): Filter by user ID
- `subject` (optional): Filter by subject
- `status` (optional): Filter by status
- `startDate` (optional): Filter by start date
- `endDate` (optional): Filter by end date
- `limit` (optional): Number of results (default: 100)
- `offset` (optional): Pagination offset (default: 0)

**Response:**
```json
{
  "success": true,
  "submissions": [...],
  "total": 250,
  "limit": 100,
  "offset": 0
}
```

#### GET /api/homework/admin/stats/:userId
Get specific user's homework statistics (admin only).

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Response:**
```json
{
  "success": true,
  "userId": "uuid",
  "stats": { ... }
}
```

## iOS Integration

### BackendAPIService Methods

```swift
// Track homework submission
func trackHomeworkSubmission(problem: HomeworkProblem) async throws

// Update homework completion
func updateHomeworkCompletion(problemId: UUID, completionData: [String: Any]) async throws

// Get user homework stats
func getUserHomeworkStats() async throws -> HomeworkStats
```

### Usage in HomeView

When a homework problem is analyzed and created:
```swift
// Track homework submission to backend
Task {
    do {
        try await backendService.trackHomeworkSubmission(problem: problem)
    } catch {
        print("⚠️ Failed to track homework submission: \(error)")
        // Don't fail the whole flow if tracking fails
    }
}
```

### Usage in StepGuidanceView

When a homework problem is completed:
```swift
// Track homework completion to backend
Task {
    do {
        let totalHintsUsed = steps.reduce(0) { $0 + $1.hintsUsed }
        let completionData: [String: Any] = [
            "completedSteps": problem.completedSteps,
            "skippedSteps": problem.skippedSteps,
            "status": "completed",
            "timeSpentSeconds": 0,
            "hintsUsed": totalHintsUsed
        ]
        try await BackendAPIService.shared.updateHomeworkCompletion(
            problemId: problemId,
            completionData: completionData
        )
    } catch {
        print("⚠️ Failed to track homework completion: \(error)")
    }
}
```

## Data Flow

### Submission Tracking
1. User uploads homework image in iOS app
2. Image is analyzed and problem is created
3. iOS app calls `POST /api/homework/submit`
4. Backend creates `homework_submissions` record
5. Backend increments `users.total_homework_submissions`
6. Returns updated total to app

### Completion Tracking
1. User completes all steps of homework
2. iOS app calls `PUT /api/homework/complete/:problemId`
3. Backend updates `homework_submissions` record
4. Sets `completed_at` timestamp
5. Records final statistics

### Deletion Behavior
- When user deletes problem from iOS app:
  - Local data is removed
  - Backend record remains intact
  - `total_homework_submissions` counter unchanged
- Analytics always show complete history

## Analytics Queries

### Get total submissions by user
```sql
SELECT user_id, username, total_homework_submissions
FROM users
ORDER BY total_homework_submissions DESC;
```

### Get completion rate by user
```sql
SELECT 
    u.username,
    COUNT(*) as total_submissions,
    SUM(CASE WHEN hs.status = 'completed' THEN 1 ELSE 0 END) as completed,
    ROUND(100.0 * SUM(CASE WHEN hs.status = 'completed' THEN 1 ELSE 0 END) / COUNT(*), 2) as completion_rate
FROM homework_submissions hs
JOIN users u ON hs.user_id = u.user_id
GROUP BY u.user_id, u.username
ORDER BY completion_rate DESC;
```

### Get average time by subject
```sql
SELECT 
    subject,
    COUNT(*) as submissions,
    AVG(time_spent_seconds) as avg_time,
    AVG(hints_used) as avg_hints
FROM homework_submissions
WHERE status = 'completed'
GROUP BY subject
ORDER BY submissions DESC;
```

### Get daily submission trends
```sql
SELECT 
    DATE(submitted_at) as date,
    COUNT(*) as submissions,
    COUNT(DISTINCT user_id) as unique_users
FROM homework_submissions
WHERE submitted_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(submitted_at)
ORDER BY date DESC;
```

## Deployment

### Step 1: Apply Migration
```bash
cd backend
./deploy-homework-tracking.sh
```

Or manually:
```bash
psql "$DATABASE_URL" -f migrations/005_add_homework_tracking.sql
```

### Step 2: Deploy Backend
Deploy updated backend to Azure with new routes and services.

### Step 3: Deploy iOS App
Deploy updated iOS app with homework tracking integration.

### Step 4: Verify
- Test homework submission
- Check database for new records
- Verify admin endpoints
- Monitor logs for tracking success

## Error Handling

The system is designed to fail gracefully:
- If tracking fails, homework submission still succeeds
- Errors are logged but don't block user flow
- Retry logic can be added if needed
- Admin can manually reconcile data if needed

## Privacy & Compliance

- All homework data is tied to user accounts
- Deleting user account cascades to `homework_submissions`
- Image filenames stored but not image data
- GDPR/CCPA compliant with CASCADE DELETE

## Future Enhancements

- [ ] Add retry logic for failed tracking
- [ ] Implement time tracking for each step
- [ ] Add homework difficulty ratings
- [ ] Track common mistakes by subject
- [ ] Add homework streaks and achievements
- [ ] Export homework history for students
- [ ] Parent/teacher dashboard integration

