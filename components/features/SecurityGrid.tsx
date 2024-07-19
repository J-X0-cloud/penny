import { Icon } from "@/components/ui/Icon";
import { SectionHead } from "@/components/ui/SectionHead";
import { SECURITY_FEATURES } from "@/lib/data/features";

export function SecurityGrid() {
  return (
    <section className="sec sec-dark" id="security">
      <div className="wrap">
        <SectionHead
          tone="light"
          eyebrow="Security & privacy"
          title={
            <>
              Built like it&rsquo;s <em>your money.</em> Because it is.
            </>
          }
        />
        <div className="sec-grid">
          {SECURITY_FEATURES.map((item) => (
            <div key={item.title} className="sec-tile">
              <Icon name={item.icon} />
              <h3>{item.title}</h3>
              <p>{item.body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
