'use client';
import { useMemo, useState } from 'react';

const products = [
  {id:1,icon:'🥔',name:'Potatoes',price:15,unit:'kg',location:'Teyateyaneng',farmer:'Mpho Farm',category:'Vegetables',qty:'500 kg'},
  {id:2,icon:'🍅',name:'Tomatoes',price:18,unit:'kg',location:'Maseru',farmer:'Thaba Produce',category:'Vegetables',qty:'220 kg'},
  {id:3,icon:'🥚',name:'Fresh Eggs',price:65,unit:'tray',location:'Leribe',farmer:'Nala Poultry',category:'Livestock',qty:'80 trays'},
  {id:4,icon:'🌽',name:'Maize',price:9,unit:'kg',location:'Mafeteng',farmer:'Khotso Farm',category:'Grains',qty:'1,000 kg'},
  {id:5,icon:'🥬',name:'Cabbage',price:12,unit:'head',location:'Maseru',farmer:'Makoanyane Farm',category:'Vegetables',qty:'350 heads'},
  {id:6,icon:'🍓',name:'Strawberries',price:55,unit:'box',location:'Roma',farmer:'Roma Fresh',category:'Fruit',qty:'60 boxes'}
];

export default function Marketplace(){
 const [q,setQ]=useState(''); const [category,setCategory]=useState('All');
 const filtered=useMemo(()=>products.filter(p=>(category==='All'||p.category===category)&&(`${p.name} ${p.location} ${p.farmer}`.toLowerCase().includes(q.toLowerCase()))),[q,category]);
 return <main className="shell"><nav className="nav"><a className="brand" href="/">🌱 AgriLink</a><div className="navlinks"><a href="/marketplace">Marketplace</a><a href="/sell">Sell</a><a href="/about">How it works</a></div><a className="btn primary" href="/sell">Sell produce</a></nav><section className="section"><span className="badge">MARKETPLACE</span><h1>Find fresh produce</h1><p className="muted">Discover products from farmers around Lesotho.</p><div className="search"><input value={q} onChange={e=>setQ(e.target.value)} placeholder="Search potatoes, eggs, Maseru..."/><a className="btn primary" href="#listings">Search</a></div><div className="actions">{['All','Vegetables','Fruit','Grains','Livestock'].map(c=><button className={'btn '+(category===c?'primary':'secondary')} onClick={()=>setCategory(c)} key={c}>{c}</button>)}</div><div id="listings" className="product-grid">{filtered.map(p=><article className="product" key={p.id}><div className="product-img">{p.icon}</div><div className="product-body"><span className="badge">{p.category}</span><h3>{p.name}</h3><p><b>M{p.price}</b> / {p.unit}</p><p>📍 {p.location} · {p.qty}</p><p>👨‍🌾 {p.farmer}</p><a className="btn primary" href={'/product/'+p.id}>View listing</a></div></article>)}</div>{filtered.length===0&&<div className="card" style={{marginTop:20}}>No listings match your search yet.</div>}</section></main>;
}
