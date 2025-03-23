
# Health Monitoring Screen

This Flutter screen provides an interface for users to track their health by recording symptoms, visualizing serology data through interactive graphs, and accessing disease-related information.

## Features

### 1. **Serology Graphs**
   - Allows users to input and visualize their serology data.
   - Provides an interactive and intuitive graphing system.
   - Supports comparisons over time to help users monitor trends and patterns.

### 2. **Symptom Tracking**
   - Users can log symptoms regularly to monitor their health progression.
   - Includes a timeline view for recorded symptoms.
   - Enables exporting symptom logs for sharing with healthcare professionals.

### 3. **Disease Information**
   - Offers educational content about specific diseases.
   - Provides prevention tips, symptom explanations, and general health advice.
   - Links to reliable resources for further reading.

## User Guide

### **Navigating the Screen**
   - The main interface consists of:
     1. **Graph Section**: Displays serology trends based on user inputs.
     2. **Symptom Tracking Section**: Allows adding and reviewing symptoms.
     3. **Information Section**: Provides disease-related articles and tips.

### **Interacting with Graphs**
   - Input serology data via the provided form.
   - Select the desired date range to view specific data.
   - Pinch to zoom and scroll through the graphs for detailed inspection.

### **Recording Symptoms**
   - Tap the "Add Symptom" button to log a new entry.
   - Choose from a predefined list of symptoms or input custom ones.
   - Add optional notes for context or severity ratings.

### **Accessing Disease Information**
   - Tap on the "Information" tab to view educational articles.
   - Use the search bar to find specific topics.
   - Share articles via the "Share" button.

## Technical Details

### **Dependencies**
This screen uses the following Flutter packages:
   - [`fl_chart`](https://pub.dev/packages/fl_chart): For creating interactive serology graphs.
   - [`provider`](https://pub.dev/packages/provider): For state management.
   - [`shared_preferences`](https://pub.dev/packages/shared_preferences): For local storage of user data.

### **State Management**
   - `ChangeNotifier` is used for managing the state of symptom logs and serology data.
   - Locale support for multilingual information display (e.g., English, French, Arabic).

### **Data Storage**
   - User inputs are stored locally using `SharedPreferences`.
   - Data can be exported as a CSV file.

### **Future Enhancements**
   - Integration with external APIs for personalized health advice.
   - Cloud sync for user data.
   - Notifications for symptom updates and health tips.


## Contribution Guidelines
Contributions are welcome! Please follow these steps:
1. Fork this repository.
2. Create a feature branch: `git checkout -b feature-name`.
3. Commit your changes: `git commit -m "Add feature"`.
4. Push to the branch: `git push origin feature-name`.
5. Create a pull request.

## License
This project is licensed under the MIT License.

---

This README template provides a clear overview of the screen's purpose and functionality, with technical insights for developers and user instructions for end-users. Let me know if you'd like to refine any specific section!