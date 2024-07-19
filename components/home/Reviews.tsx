import { SectionHead } from "@/components/ui/SectionHead";
import { TESTIMONIALS } from "@/lib/data/marketing";

export function Reviews() {
  return (
    <section className="sec" id="reviews">
      <div className="wrap">
        <SectionHead
          eyebrow="From early members"
          title={
            <>
              Less tallying, <em>more deciding.</em>
            </>
          }
        />
        <div className="quotes">
          {TESTIMONIALS.map((t) => (
            <figure key={t.name} className="quote">
              <div className="stars" aria-label="5 out of 5">
                ★★★★★
              </div>
              <blockquote>{t.quote}</blockquote>
              <figcaption>
                <span className="av">{t.name[0]}</span>
                <b>{t.name}</b>
                <small>{t.location}</small>
              </figcaption>
            </figure>
          ))}
        </div>
      </div>
    </section>
  );
}
