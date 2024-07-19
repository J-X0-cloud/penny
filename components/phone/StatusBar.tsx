export function StatusBar() {
  return (
    <div className="ps-status">
      <span>9:41</span>
      <span className="ps-sys">
        <svg viewBox="0 0 18 12" aria-hidden="true">
          <rect x="0" y="8" width="3" height="4" rx="1" />
          <rect x="5" y="5.5" width="3" height="6.5" rx="1" />
          <rect x="10" y="3" width="3" height="9" rx="1" />
          <rect x="15" y="0" width="3" height="12" rx="1" />
        </svg>
        <svg viewBox="0 0 16 12" aria-hidden="true">
          <path d="M8 2.2c2.4 0 4.6.9 6.2 2.5l1.3-1.3A10.6 10.6 0 0 0 8 .3 10.6 10.6 0 0 0 .5 3.4l1.3 1.3A8.8 8.8 0 0 1 8 2.2zm0 3.7c1.4 0 2.7.6 3.6 1.5l1.3-1.3A7 7 0 0 0 8 4a7 7 0 0 0-4.9 2.1l1.3 1.3c1-.9 2.2-1.5 3.6-1.5zm0 3.6c.5 0 .9.2 1.2.5L8 11.2 6.8 10c.3-.3.7-.5 1.2-.5z" />
        </svg>
        <svg viewBox="0 0 27 12" aria-hidden="true">
          <rect x=".5" y=".5" width="23" height="11" rx="3.2" fill="none" stroke="currentColor" opacity=".45" />
          <rect x="2" y="2" width="17" height="8" rx="2" />
          <rect x="24.6" y="4" width="1.6" height="4" rx=".8" opacity=".5" />
        </svg>
      </span>
    </div>
  );
}
