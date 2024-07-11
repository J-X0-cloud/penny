import type { FaqItem } from "@/types";

export function FaqList({ items }: { items: FaqItem[] }) {
  return (
    <div>
      {items.map((item, i) => (
        <details key={item.question} className="faq" open={i === 0}>
          <summary>
            {item.question}
            <span />
          </summary>
          <p>{item.answer}</p>
        </details>
      ))}
    </div>
  );
}
