import { Icon } from "@/components/ui/Icon";
import { COMPARE_ROWS } from "@/lib/data/pricing";

function Mark({ included }: { included: boolean }) {
  return included ? <Icon name="check" /> : <span className="no">–</span>;
}

export function CompareTable() {
  return (
    <div className="cmp-wrap">
      <table className="cmp">
        <thead>
          <tr>
            <th />
            <th>Penny</th>
            <th>Household</th>
          </tr>
        </thead>
        <tbody>
          {COMPARE_ROWS.map((row) => (
            <tr key={row.feature}>
              <td>{row.feature}</td>
              <td>
                <Mark included={row.penny} />
              </td>
              <td>
                <Mark included={row.household} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
