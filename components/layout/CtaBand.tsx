import Image from "next/image";
import { Button } from "@/components/ui/Button";

interface CtaBandProps {
  title?: string;
  body?: string;
}

export function CtaBand({
  title = "Give every dollar a job this month.",
  body = "Start a 14-day free trial on iPhone or the web. No card needed to look around.",
}: CtaBandProps) {
  return (
    <section className="cta-band">
      <div className="wrap cta-in">
        <Image className="cta-illo a" src="/images/goal-home.webp" alt="" width={160} height={160} />
        <Image className="cta-illo b" src="/images/cat-groceries.webp" alt="" width={120} height={120} />
        <h2>{title}</h2>
        <p>{body}</p>
        <div className="btns">
          <Button href="/pricing" variant="copper">
            Start free trial
          </Button>
          <Button href="/app" variant="line-w">
            Tour the app
          </Button>
        </div>
      </div>
    </section>
  );
}
