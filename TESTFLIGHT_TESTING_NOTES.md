# 🧪 **What to Test - Homework Helper v1.0 (Build 1)**

## ✅ **Azure Key Vault Pre-Configured**

**Good news! The app is now configured to use Azure Key Vault automatically:**

- **No manual setup required** - Azure Key Vault is pre-configured
- **API key is fetched automatically** from Azure
- **Seamless operation** for all testers
- **Settings will show "Azure Key Vault Configured"**

**If you see an API key error, please report it as a bug.**

---

## 📸 **Core Functionality**

### **1. Homework Upload & Analysis**
- [ ] Take a photo of homework using **Camera** button
- [ ] Upload homework image from **Photo Library**
- [ ] Verify app correctly reads numbers and values from the image
- [ ] Test with different subjects: Math, Science, English, History
- [ ] Try multiple problems on one worksheet (app should solve ALL of them)

### **2. Step-by-Step Guidance**
- [ ] Work through all steps for a complete problem
- [ ] Select correct answers from multiple choice options
- [ ] Select wrong answers and verify feedback is helpful
- [ ] Test that app doesn't reveal answers in questions
- [ ] Verify each step builds toward the final answer

### **3. Navigation**
- [ ] Use **← Previous** button to go back to earlier steps
- [ ] Verify back button shows "Home" on first step
- [ ] Complete homework and test **"Try This Homework Again"** button
- [ ] Test **"Start New Homework"** button
- [ ] Test **"Back to Home"** button after completion

## 🎓 **Age-Appropriate Features**

### **4. Grade Level Testing** (IMPORTANT)
Test with different grade levels:
- [ ] **Elementary (K-5):** Hints should use simple language (e.g., "5 + 5 + 3 + 3" not "2×(5+3)")
- [ ] **Middle School (6-8):** Can introduce formulas with explanations
- [ ] **High School (9-12):** Should use proper mathematical notation

### **5. Hint System**
- [ ] Request hints during problem solving
- [ ] Verify hints are helpful but don't give away answers
- [ ] Check hints match appropriate grade level
- [ ] Test hints with visual/concrete examples for young students

## 🎨 **Animations & UI**

### **6. Launch Experience**
- [ ] First launch: Watch for "Homework Made Easier Without Cheating" animation
- [ ] Listen for fireworks sounds (3 different sounds)
- [ ] Animation should last 4 seconds

### **7. Big Brain Animation**
- [ ] Tap the cartoon head on home page
- [ ] Verify hand taps head with animation
- [ ] Listen for "BIG BRAIN!" or other phrases spoken aloud
- [ ] Text bubble should appear and disappear smoothly

## ⚙️ **Settings & Legal**

### **8. Settings Features**
- [ ] Test Azure Key Vault status (should show "Not configured" for TestFlight)
- [ ] Tap **Contact Us** and copy email address (homework@arshia.com)
- [ ] Read **Important Disclaimer** - verify it's clear
- [ ] Review **Privacy Policy** - check for completeness
- [ ] Review **Terms of Use** - ensure readability
- [ ] Test **Reset All Data** function (warning: deletes everything!)

### **9. Profile & Progress**
- [ ] Set up profile with name, age, and grade
- [ ] Complete homework and verify points are awarded
- [ ] Check streak counter updates
- [ ] View progress stats

## 🐛 **Known Issues to Watch For**

### **Critical to Report:**
- [ ] Wrong answers being marked as correct
- [ ] App skipping problems on worksheet
- [ ] Hallucinated/incorrect values read from images
- [ ] Answers revealed in question text
- [ ] App freezing or crashing
- [ ] Navigation issues (jumping steps, getting stuck)

### **Expected Behavior:**
- ✅ Launch animation plays once per session
- ✅ Big Brain animation can be triggered multiple times
- ✅ Back button takes you to previous step (not home)
- ✅ All problems on worksheet must be completed
- ✅ Verification happens via OpenAI (may take 1-2 seconds)

## 📝 **Testing Scenarios**

### **Scenario 1: Simple Math Problem**
1. Upload image with 3-5 basic math problems
2. Work through ALL problems step by step
3. Verify final answers are correct
4. Test hints at each step

### **Scenario 2: Rectangle Perimeter (Grade Level Test)**
1. Upload geometry homework with rectangles
2. Set profile to Elementary (age 10)
3. Check if hints use "length + length + width + width"
4. Verify NO formulas like "2×(l+w)" appear

### **Scenario 3: Multi-Problem Worksheet**
1. Upload homework with 5+ problems
2. Verify app creates steps for EVERY problem
3. Count total steps = ~3-5 steps × number of problems
4. Ensure app doesn't finish until all solved

### **Scenario 4: Navigation Flow**
1. Start homework, complete 3 steps
2. Hit back button twice (should go to step 1)
3. Go forward to step 5
4. Complete all problems
5. Choose "Try Again" and verify it restarts

## 💬 **Feedback We Need**

Please report:
1. **Accuracy:** Were AI-generated answers correct?
2. **Completeness:** Did app solve all problems on your worksheet?
3. **Age-Appropriateness:** Were explanations suitable for grade level?
4. **Usability:** Was navigation intuitive?
5. **Performance:** Any lag, crashes, or freezing?
6. **Animations:** Did sounds and animations work properly?

## 📧 **Contact for Issues**

If you encounter bugs or have questions:
- Email: **homework@arshia.com**
- Include: iOS version, device model, and steps to reproduce

---

**Thank you for testing Homework Helper!** 🎓✨

**Note:** This is a beta build. Some features are still being refined based on your feedback.
