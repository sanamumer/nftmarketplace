
import '../styles/globals.css'
import Link from 'next/link'

function MyApp({ Component, pageProps }) {
  return (
    <div>
      <nav className="border-b p-6">
        <p className="text-4xl font-bold ">CLASSY CHAIN</p>
        <div className="flex mt-4">
          <Link href="/"className="mr-4 text-blue-500">Home</Link>
          <Link href="/create-nft"className="mr-6 text-blue-500">Sell Item</Link>
          <Link href="/my-nfts"className="mr-6 text-blue-500">My Items </Link>
          {/* <Link href="/resell-nft"className="mr-6 text-blue-500">Resell </Link> */}
          <Link href="/dashboard"className="mr-6 text-blue-500">Creator Dashboard </Link>
        </div>
      </nav>
      <Component {...pageProps} />
    </div>
  )
}

export default MyApp