import { Fragment, type ReactNode } from 'react';

// Minimal markdown: **bold**, *italic*, `code`, pipe tables, \n paragraphs.
// Question data is authored in this dialect; no external parser needed.

function inline(text: string): ReactNode[] {
  const out: ReactNode[] = [];
  const re = /(\*\*([^*]+)\*\*)|(\*([^*]+)\*)|(`([^`]+)`)/g;
  let last = 0;
  let m: RegExpExecArray | null;
  let k = 0;
  while ((m = re.exec(text))) {
    if (m.index > last) out.push(text.slice(last, m.index));
    if (m[2] !== undefined) out.push(<strong key={k++}>{m[2]}</strong>);
    else if (m[4] !== undefined) out.push(<em key={k++}>{m[4]}</em>);
    else if (m[6] !== undefined) out.push(<code key={k++}>{m[6]}</code>);
    last = m.index + m[0].length;
  }
  if (last < text.length) out.push(text.slice(last));
  return out;
}

function isTableLine(l: string) {
  const t = l.trim();
  return t.startsWith('|') && t.endsWith('|') && t.length > 2;
}

function splitRow(l: string): string[] {
  return l.trim().replace(/^\||\|$/g, '').split('|').map((c) => c.trim());
}

export function Md({ text, className }: { text: string; className?: string }) {
  const lines = text.split('\n');
  const blocks: ReactNode[] = [];
  let i = 0;
  let key = 0;

  while (i < lines.length) {
    if (isTableLine(lines[i])) {
      const tbl: string[] = [];
      while (i < lines.length && isTableLine(lines[i])) tbl.push(lines[i++]);
      const rows = tbl.map(splitRow).filter((r) => !r.every((c) => /^[-:\s]*$/.test(c)));
      if (rows.length) {
        const [head, ...body] = rows;
        blocks.push(
          <div key={key++} className="overflow-x-auto">
            <table>
              <thead>
                <tr>{head.map((c, j) => <th key={j}>{inline(c)}</th>)}</tr>
              </thead>
              <tbody>
                {body.map((r, ri) => (
                  <tr key={ri}>{r.map((c, j) => <td key={j}>{inline(c)}</td>)}</tr>
                ))}
              </tbody>
            </table>
          </div>,
        );
      }
      continue;
    }
    // group consecutive non-table lines into one paragraph block with <br/>
    const para: string[] = [];
    while (i < lines.length && !isTableLine(lines[i])) para.push(lines[i++]);
    // drop trailing/leading empties but keep internal structure
    const trimmed = para.join('\n').replace(/^\n+|\n+$/g, '');
    if (trimmed) {
      blocks.push(
        <p key={key++}>
          {trimmed.split('\n').map((l, j, arr) => (
            <Fragment key={j}>
              {inline(l)}
              {j < arr.length - 1 && <br />}
            </Fragment>
          ))}
        </p>,
      );
    }
  }

  return <div className={`md ${className ?? ''}`}>{blocks}</div>;
}
