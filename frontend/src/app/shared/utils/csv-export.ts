/**
 * Builds a CSV string from an array of plain row objects and triggers a
 * client-side download via a Blob + temporary anchor element.
 */
export function exportRowsToCsv(
  filename: string,
  headers: string[],
  rows: (string | number)[][],
): void {
  const escapeCell = (cell: string | number): string => {
    const value = String(cell ?? '');
    if (/[",\n]/.test(value)) {
      return `"${value.replace(/"/g, '""')}"`;
    }
    return value;
  };

  const lines = [headers, ...rows].map((row) => row.map(escapeCell).join(','));
  // BOM so Excel opens Arabic UTF-8 content correctly.
  const csvContent = '\uFEFF' + lines.join('\r\n');

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}
