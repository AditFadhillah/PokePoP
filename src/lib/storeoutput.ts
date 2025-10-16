export async function runAndSavePython(pyodide: any, code: string, filename = 'output.txt') {
  const wrappedCode = `
import sys
from io import StringIO

sys.stdout = sys.stderr = mystdout = StringIO()

def __run_user_code__():
${code.split('\n').map(line => '  ' + line).join('\n')}

try:
    result = __run_user_code__()
except Exception as e:
    result = str(e)

output_text = mystdout.getvalue()
result_repr = repr(result)
output_text + ('\\n' + result_repr if result_repr not in ['None', ''] else '')
`

  const outputText = await pyodide.runPythonAsync(wrappedCode)
  const blob = new Blob([outputText], { type: 'text/plain' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  a.click()
  URL.revokeObjectURL(url)

  return outputText
}

// Run Python code and return printed output
export async function runPython(pyodide: any, code: string): Promise<string> {
  if (!pyodide) return '❌ Pyodide not loaded';

  try {
    // Redirect stdout and stderr so we can capture print() output
    await pyodide.runPythonAsync(`
            import sys
            from io import StringIO
            sys.stdout = sys.stderr = mystdout = StringIO()
                `);

    // Run user code directly
    await pyodide.runPythonAsync(code);

    // Get what was printed
    const outputText = await pyodide.runPythonAsync("mystdout.getvalue()");

    // Return printed text or fallback message
    //factorise this. The print method should be different. 
    // In case we need to compare the result. 
    // we need to store it as a sson. 
    return outputText.trim() || '✅ No output';

  } catch (err: any) {
    return '❌ Error: ' + err.message;
  }
}
