import dynamic from 'next/dynamic';

const TrollRunClient = dynamic(() => import('./TrollRunClient'), { ssr: false });
export default function TrollRunPage() { return <TrollRunClient />; }
