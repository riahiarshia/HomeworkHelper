# Adding Authentication Files to Xcode Project

The build is failing because the authentication files need to be manually added to the Xcode project. Follow these steps:

## Step 1: Open Xcode Project
```bash
open HomeworkHelper.xcodeproj
```

## Step 2: Add AuthenticationService.swift to Services Group

1. In Xcode, expand the **Services** group in the Project Navigator
2. Right-click on the **Services** group
3. Select **"Add Files to 'HomeworkHelper'"**
4. Navigate to: `HomeworkHelper/Services/AuthenticationService.swift`
5. Ensure **"Add to target: HomeworkHelper"** is checked
6. Click **"Add"**

## Step 3: Create Authentication Group in Views

1. Right-click on the **Views** group in the Project Navigator
2. Select **"New Group"**
3. Name it **"Authentication"**

## Step 4: Add Authentication Views

1. Right-click on the new **Authentication** group
2. Select **"Add Files to 'HomeworkHelper'"**
3. Navigate to: `HomeworkHelper/Views/Authentication/`
4. Select all three files:
   - `AuthenticationView.swift`
   - `SignInView.swift`
   - `SignUpView.swift`
5. Ensure **"Add to target: HomeworkHelper"** is checked
6. Click **"Add"**

## Step 5: Build and Test

1. Press **⌘+B** to build the project
2. If build succeeds, run the app with **⌘+R**
3. Test the authentication flow

## Expected Result

After adding the files, you should see:
- **Services** group containing `AuthenticationService.swift`
- **Authentication** group under **Views** containing the three authentication view files
- Successful build without compilation errors
- Authentication screens appearing when the app launches

## Troubleshooting

If you encounter issues:
1. Make sure all files are added to the **HomeworkHelper** target
2. Check that file paths are correct in the project navigator
3. Clean the build folder (**⌘+Shift+K**) and rebuild
4. Restart Xcode if needed

## Files to Add

The following files need to be added to the project:
- `HomeworkHelper/Services/AuthenticationService.swift`
- `HomeworkHelper/Views/Authentication/AuthenticationView.swift`
- `HomeworkHelper/Views/Authentication/SignInView.swift`
- `HomeworkHelper/Views/Authentication/SignUpView.swift`

Once these files are properly added to the Xcode project, the authentication system will work correctly.
