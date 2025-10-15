# Teacher Method Feature

## Overview

This feature allows students to optionally provide a photo of their teacher's preferred method for solving a math problem. When enabled, the AI tutor will follow the exact method, steps, and approach shown in the teacher's example to guide the student through their homework.

## User Flow

1. **Student uploads homework problem**
   - Takes a photo of the homework problem using camera or photo library
   - Crops the image to focus on the specific problem

2. **Teacher method prompt appears**
   - After cropping, a prompt asks: "Does your teacher want you to use a specific method to solve this problem?"
   - Student can choose:
     - **Yes** - Proceed to capture teacher's method example
     - **No** - Continue with any appropriate solving method

3. **Capture teacher's method (if Yes)**
   - Student is prompted to take a photo of an example showing the teacher's preferred method
   - Can use camera or photo library
   - Crops the image to focus on the method example

4. **AI analyzes both images**
   - The problem image and teacher method image are sent to the backend
   - OpenAI analyzes both images and creates step-by-step guidance that follows the teacher's exact method
   - Steps reference the teacher's approach: "As your teacher showed..." or "Following your teacher's method..."

## Technical Implementation

### iOS App Changes

#### 1. **HomeworkProblem Model** (`HomeworkHelper/Models/HomeworkProblem.swift`)
- Added `teacherMethodImageFilename: String?` property to store the filename of the teacher method image

#### 2. **TeacherMethodPromptView** (`HomeworkHelper/Views/TeacherMethodPromptView.swift`)
- New SwiftUI view that displays the teacher method prompt
- Beautiful gradient background matching app theme
- Two main buttons: "Yes, show me how to take a photo" and "No, use any method"

#### 3. **HomeView Updates** (`HomeworkHelper/Views/HomeView.swift`)
- Added state variables for teacher method workflow:
  - `showTeacherMethodPrompt: Bool` - Controls teacher method prompt visibility
  - `teacherMethodImage: UIImage?` - Stores the captured teacher method image
  - `showTeacherMethodCamera: Bool` - Controls camera sheet for teacher method
  - `showTeacherMethodImagePicker: Bool` - Controls photo library sheet for teacher method
  - `showTeacherMethodCropper: Bool` - Controls image cropper for teacher method
  - `tempTeacherMethodImage: UIImage?` - Temporary storage during capture
  - `isCapturingTeacherMethod: Bool` - Controls image source selection alert

- Modified `analyzeImageWithQualityCheck()`:
  - Now shows teacher method prompt instead of immediately starting analysis
  - Saves the problem image for later use

- Added new methods:
  - `showTeacherMethodChoice()` - Shows alert to choose camera or photo library
  - `proceedWithAnalysis()` - Starts analysis with both images
  - `performImageAnalysis(problemImage:teacherMethodImage:)` - Main analysis function supporting optional teacher method image

#### 4. **BackendAPIService Updates** (`HomeworkHelper/Services/BackendAPIService.swift`)
- Updated `analyzeHomework()` signature to include optional `teacherMethodImageData: Data?` parameter
- Added teacher method image to multipart form data when provided
- Sends both problem image and teacher method image to backend

#### 5. **DataManager Updates** (`HomeworkHelper/Services/DataManager.swift`)
- Updated `saveImage()` to support optional `suffix` parameter
- Allows saving multiple images for the same problem (e.g., problem image and method image with "_method" suffix)

### Backend Changes

#### 1. **Image Analysis Route** (`backend/routes/imageAnalysis.js`)
- Updated `/api/analyze-homework` endpoint to accept two images:
  - `image` - The homework problem image
  - `teacherMethodImage` - The teacher's method example (optional)
- Changed from `upload.single('image')` to `upload.fields()` to handle multiple files
- Passes `teacherMethodImageData` to OpenAI service

#### 2. **OpenAI Service** (`backend/services/openaiService.js`)
- Updated `analyzeHomework()` signature to include `teacherMethodImageData` parameter

- **System Prompt Enhancement**:
  - Added "TEACHER'S METHOD (CRITICAL)" section
  - When teacher method is provided:
    - AI MUST follow the exact method shown in the teacher's example
    - Uses same terminology, notation, and step sequence
    - References the teacher's method in step explanations
  - When no teacher method provided:
    - AI uses any appropriate solving method

- **User Prompt Enhancement**:
  - Added instructions to analyze both images when teacher method is provided
  - Prompts AI to study the teacher's example first
  - Requires AI to replicate the exact method for the student's problem

- **Message Array Update**:
  - Sends both images to OpenAI's vision API
  - Problem image is sent first with "high" detail
  - Teacher method image follows with explanatory text and "high" detail
  - OpenAI can analyze both images in context

## Benefits

1. **Alignment with Classroom Teaching**: Students learn the exact method their teacher expects
2. **Consistency**: Reduces confusion from different solving approaches
3. **Better Grades**: Students can demonstrate the specific method required by their teacher
4. **Flexibility**: Optional feature - students can skip if no specific method is required
5. **Comprehensive Learning**: AI provides detailed explanations following the teacher's approach

## Example Use Cases

### Use Case 1: Long Division Method
- **Problem**: Student needs to solve a division problem
- **Teacher's Method**: Teacher requires the "long division" format with specific steps
- **Result**: AI guides student through long division exactly as teacher demonstrated

### Use Case 2: Algebraic Equations
- **Problem**: Solve for x in an equation
- **Teacher's Method**: Teacher shows a specific order of operations and layout
- **Result**: AI follows the exact sequence and notation shown by the teacher

### Use Case 3: Geometry Proofs
- **Problem**: Prove two triangles are congruent
- **Teacher's Method**: Teacher uses a specific proof format with given-prove-proof structure
- **Result**: AI structures the proof exactly as the teacher's example

## Data Storage

- Problem images are saved as: `{problemId}.jpg`
- Teacher method images are saved as: `{problemId}_method.jpg`
- Both images are stored locally in the app's documents directory
- Filenames are tracked in the `HomeworkProblem` model

## API Changes

### Request Format
```
POST /api/analyze-homework
Content-Type: multipart/form-data

Fields:
- image: File (required if no problemText)
- teacherMethodImage: File (optional)
- problemText: String (optional)
- userGradeLevel: String
- userId: String (optional)
- deviceId: String (optional)
```

### Response Format
```json
{
  "subject": "Math",
  "difficulty": "medium",
  "steps": [
    {
      "question": "Following your teacher's method: Step 1...",
      "explanation": "As your teacher showed in the example...",
      "options": ["A", "B", "C", "D"],
      "correctAnswer": "B"
    }
  ],
  "finalAnswer": "42"
}
```

## Future Enhancements

1. **Method Library**: Save commonly used teacher methods for reuse
2. **Method Recognition**: Auto-detect the type of method from the image
3. **Multi-Method Support**: Allow multiple solving methods with comparison
4. **Teacher Portal**: Allow teachers to upload preferred methods for their students
5. **Method Validation**: Verify that the captured method is appropriate for the problem type

## Testing Recommendations

1. **Test with various subjects**: Math, Science, etc.
2. **Test with different method types**: Long division, FOIL method, order of operations, etc.
3. **Test image quality**: Ensure both clear and slightly blurry method images work
4. **Test without teacher method**: Verify standard flow still works
5. **Test cancellation**: User cancels at teacher method prompt or image capture

## Error Handling

- If teacher method image fails to upload, analysis continues with just the problem image
- If AI cannot clearly see the teacher's method, it will use a standard approach and warn the student
- All existing error handling for problem images applies to teacher method images

## Privacy & Security

- Teacher method images are stored locally on device
- Images are sent securely to backend over HTTPS
- Images are not permanently stored on backend servers
- Usage tracking includes flag for whether teacher method was used (no actual image data logged)



