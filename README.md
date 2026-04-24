# Postra Landing Page

Postra（Mac 用フォト・キュレーション + 組写真レイアウトアプリ）の公式ランディングページ。

## 構成

- `index.html` — LP 本体（単一ファイル、CSS/JS インライン）
- `colors_and_type.css` — 参考用トークン（実体は index.html の `:root` に定義済み）
- `assets/` — ロゴ・アイコン画像
- `HANDOFF.md` — デザイナーからの引き継ぎ文書（セクション構成・残タスク・編集方針）

## ローカル確認

```sh
# 任意の静的サーバーで index.html を開く
python3 -m http.server 8000
# → http://localhost:8000/
```

または VS Code の Live Server 拡張などでも OK。

## デプロイ想定

- Cloudflare Pages または GitHub Pages（静的ホスティング）
- ビルド不要（`index.html` をそのまま配信）
- ドメインは未定（`postra.app` / `postra.jp` / `getpostra.com` など検討中）

## 残タスク（優先順）

詳細は `HANDOFF.md` を参照。

1. **§5 レタッチ動画差込**（最優先、現状モックは実 UI と異なる）
2. §4 / §6 / §3 / §1 の動画差込
3. ヒーロー・フローの実写差し替え（CSS モック → 実写）
4. Paddle Checkout 実リンク埋込（現状 `href="#"`）
5. OGP 画像・favicon の整備
6. モバイル表示検証（375px 付近）
7. Windows 版リリース時に `後日対応予定` 表記を更新

## 方針

- ダークモード基調、cyan→purple→pink の 1 色アクセント
- 単一 HTML ファイル完結（フレームワーク不使用）
- 日本語 primary、英語版は将来 `/en/` サブパスで追加予定
- 絵文字は使わない（ブランドトーン）
- トライアル動線は復活させない（全 CTA は `#pricing` へ統一）

## 関連

- アプリ本体リポジトリ: `TosanoKoji/postra`（private）
- デザインシステム原本: `../postra-lp-design/`（同階層、参考用）
