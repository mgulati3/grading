# iOS Submission Grader

Automated tool for grading iOS assignments downloaded from Canvas. Streamlines the grading workflow by handling unzipping, MVVM architecture analysis, and cleanup automatically.

## ✨ Features

- 🗂️ **Interactive Menu** - Select submissions from a list
- 📦 **Auto Unzip** - Extracts and finds `.xcodeproj` files automatically
- 🏗️ **MVVM Analysis** - Checks architecture compliance before you grade
- 🧹 **Auto Cleanup** - Deletes zip and extracted files after grading
- 📄 **Report Generation** - Saves detailed MVVM analysis reports

## 🚀 Quick Start

### 1. Download Scripts
```bash
# Clone this repository
git clone https://github.com/yourusername/ios-grader.git
cd ios-grader

# Or download both files manually:
# - grade-ios.sh
# - mvvm-checker.sh
```

### 2. Make Scripts Executable
```bash
chmod +x grade-ios.sh
chmod +x mvvm-checker.sh
```

### 3. Configure Your Grading Folder
Edit `grade-ios.sh` and change this line:
```bash
DOWNLOAD_DIR="$HOME/Desktop/Grading"
```
Update it to your Canvas download folder path.

### 4. Run the Grader
```bash
./grade-ios.sh
```

## 📋 How to Use

1. **Download** Canvas submissions to your grading folder
2. **Run** `./grade-ios.sh`
3. **Select** the submission number from the menu
4. **Review** the MVVM analysis results
5. **Press Enter** to open Xcode
6. **Grade** the assignment manually
7. **Press Enter** when done to auto-cleanup

## 🏗️ MVVM Analysis Checks

The tool automatically analyzes projects for:

| Check | Points | Description |
|-------|--------|-------------|
| ViewModel Files | 2 | Files ending with `ViewModel.swift` |
| Model Files | 2 | Files ending with `Model.swift` |
| Folder Structure | 2 | Model/View/ViewModel folders present |
| ObservableObject | 2 | ViewModels conform to `ObservableObject` |
| @Published Properties | 2 | ViewModels use `@Published` |
| ViewModel Binding | 2 | Views use `@StateObject`/`@ObservedObject` |
| Architecture Violations | 2 | No network calls or excessive logic in Views |
| Model Purity | 2 | Models don't import UI frameworks |

**Total: 16 points**

### Score Interpretation
- **90-100%** - Excellent MVVM implementation ✅
- **75-89%** - Good implementation with minor issues ⚠️
- **50-74%** - Partial implementation ⚠️
- **< 50%** - Poor or no MVVM implementation ❌

## 📊 Example Output

```
========================================
MVVM Compliance Score: 12/16 (75%)
========================================

✓ Passes:
  • Found 2 ViewModel file(s)
  • Found @Published properties in 2 file(s)
  
✗ Issues:
  • Weak folder organization
  • Large View file (315 lines)

Grade: Good MVVM implementation with minor issues

Report saved to: MVVM_Analysis_Report.txt
```

## 💡 Benefits

### For Graders
- ⏱️ **Saves Time** - Eliminates manual unzipping and file searching
- 🎯 **Consistent Grading** - Standardized MVVM checks across all submissions
- 📝 **Documentation** - Auto-generated reports for record keeping
- 🧹 **Clean Workspace** - Automatic cleanup prevents clutter

### For Students
- 📊 **Clear Feedback** - Detailed reports show exactly what's missing
- 🎓 **Learning Tool** - Understand MVVM best practices
- ⚖️ **Fair Assessment** - Same criteria applied to everyone

### For Instructors
- 📈 **Analytics** - Track common architecture mistakes
- 🔄 **Reusable** - Works for any iOS assignment requiring MVVM
- 🤝 **Shareable** - Easy for multiple graders to use

## 🛠️ Requirements

- macOS (tested on macOS 10.15+)
- Xcode installed
- Bash shell (default on macOS)

## 📁 Project Structure

```
ios-grader/
├── grade-ios.sh          # Main grading script
├── mvvm-checker.sh       # MVVM analysis tool
└── README.md             # This file
```

## ⚙️ Configuration

Both scripts should be in the **same folder**. The main script automatically detects and runs the MVVM checker if present.

To skip MVVM analysis, simply don't include `mvvm-checker.sh`.

## 🐛 Troubleshooting

**"No zip files found"**
- Check that `DOWNLOAD_DIR` path is correct
- Ensure zip files are in the specified folder

**"Project missing project.pbxproj"**
- Submission may be corrupted
- Script will show you what was extracted for debugging

**"mapfile: command not found"**
- Use the updated script (compatible with older bash versions)

## 🤝 Contributing

Feel free to submit issues or pull requests to improve the tool!

## 📝 License

MIT License - Feel free to use and modify for educational purposes.

---

**Created for iOS Mobile Development Course Grading**

Made with ❤️ by graders, for graders.
