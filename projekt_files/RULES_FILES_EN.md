# RULES_FILES_EN.md

## 📌 Global File Rules

### 1. GLOBAL_RULE_MAKE_FILES_VIA_BASH.md
- Every file is created **only through a single bash block**.  
- Inside the block:  
  1. Always start with `cd ~/ai-agent/projects/TARGET_FOLDER` to ensure navigation to the correct location.  
  2. Create the necessary directories with `mkdir -p projekt_files/` — this prevents *"No such file or directory"* errors.  
  3. Write the file using a heredoc:
     ```bash
     cat <<'MD' > projekt_files/FILE
     ...file content...
     MD
     ```  
  4. The entire file content must be inside the heredoc.  
  5. At the end of the block you can add `cp` or other actions if required by the project.  
- No text is allowed before or after the block.  
- All path and folder logic must be **inside the code**, so pasting it into any terminal will always create the file in the correct place.  
- If you need to save **any file (no matter which one)**, it is always done in the same way: a single self-contained bash block following these rules.  

---

### 2. Follow_these_rules.md
- Everything must be executed only in Linux (bash).  
- In case of an error, always specify: file path, line, cause, and exact fix.  
- One project = one folder, with minimal sub-sectors.  
