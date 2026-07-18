<!doctype html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login Admin - Ootday</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 24 24%22><text y=%2220%22 font-size=%2220%22>🛍️</text></svg>">
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="relative bg-gradient-to-tr from-rose-50 via-slate-50 to-pink-50 min-h-screen flex items-center justify-center p-4 overflow-hidden">
    <!-- Ambient decorative blobs -->
    <div class="pointer-events-none absolute -top-24 -left-24 w-96 h-96 bg-rose-200/40 rounded-full blur-3xl"></div>
    <div class="pointer-events-none absolute -bottom-24 -right-24 w-96 h-96 bg-violet-200/40 rounded-full blur-3xl"></div>
    <div class="pointer-events-none absolute top-1/3 right-1/4 w-64 h-64 bg-pink-200/30 rounded-full blur-3xl"></div>

    <div class="relative w-full max-w-md bg-white/80 backdrop-blur-md border border-white rounded-3xl shadow-xl p-10 transform hover:scale-[1.01] transition-all duration-300 animate-modal-pop">
        <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-rose-500 to-pink-500 flex items-center justify-center text-2xl shadow-md shadow-rose-500/20 mb-6">🛍️</div>
        <h1 class="text-3xl font-black text-slate-800 tracking-tight">Ootday <span class="bg-gradient-to-r from-rose-500 via-pink-500 to-violet-600 bg-clip-text text-transparent">Admin</span></h1>
        <p class="text-sm text-slate-400 font-medium mt-1 mb-8">Masuk untuk mengelola platform Ootday</p>

        @if ($errors->any())
            <div class="hidden alert-flash-data" data-type="error" data-message="{{ $errors->first() }}"></div>
        @endif
        @if (session('success'))
            <div class="hidden alert-flash-data" data-type="success" data-message="{{ session('success') }}"></div>
        @endif

        <form method="POST" action="{{ route('login') }}" class="space-y-6" onsubmit="const b=this.querySelector('button[type=submit]'); b.disabled=true; b.dataset.label=b.innerHTML; b.innerHTML='<span class=&quot;inline-flex items-center gap-2&quot;><svg class=&quot;w-4 h-4 animate-spin&quot; fill=&quot;none&quot; viewBox=&quot;0 0 24 24&quot;><circle class=&quot;opacity-25&quot; cx=&quot;12&quot; cy=&quot;12&quot; r=&quot;10&quot; stroke=&quot;currentColor&quot; stroke-width=&quot;4&quot;></circle><path class=&quot;opacity-75&quot; fill=&quot;currentColor&quot; d=&quot;M4 12a8 8 0 018-8v8z&quot;></path></svg>Memproses...</span>';">
            @csrf
            <div>
                <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase mb-1.5">Email</label>
                <input type="email" name="email" value="{{ old('email') }}" required autofocus
                    class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm bg-white/50 focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
            </div>
            <div>
                <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase mb-1.5">Password</label>
                <input type="password" name="password" required
                    class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm bg-white/50 focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
            </div>
            <button type="submit"
                class="w-full bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 disabled:opacity-70 disabled:cursor-not-allowed text-white text-sm font-bold py-3.5 rounded-xl shadow-md shadow-rose-500/15 hover:shadow-lg hover:scale-[1.01] active:scale-[0.99] transition-all duration-200">
                Masuk
            </button>
        </form>
    </div>

    <!-- Beautiful Dialog Box Modal -->
    <div id="alertDialog" style="display: none; opacity: 0; transition: opacity 0.25s ease; background-color: rgba(15, 23, 42, 0.45); backdrop-filter: blur(4px);" class="fixed inset-0 items-center justify-center z-[9999]">
        <div id="alertDialogContent" style="transform: scale(0.95); transition: transform 0.25s ease;" class="bg-white rounded-2xl shadow-xl border border-slate-100 p-6 w-full max-w-sm">
            <div class="flex flex-col items-center text-center space-y-4">
                <!-- Icon -->
                <div id="alertDialogIcon" class="p-3 rounded-full flex items-center justify-center">
                    <!-- SVG icon injected here -->
                </div>
                <!-- Title & Message -->
                <div class="space-y-1">
                    <h3 class="text-lg font-bold text-slate-800" id="alertDialogTitle">Notifikasi</h3>
                    <p class="text-sm text-slate-500 leading-relaxed" id="alertDialogMessage"></p>
                </div>
                <!-- Action Button -->
                <button onclick="closeAlertDialog()" class="w-full mt-2 py-2.5 px-4 text-sm font-semibold text-white bg-slate-800 hover:bg-slate-900 rounded-xl shadow-sm hover:shadow transition-all duration-200">
                    OK
                </button>
            </div>
        </div>
    </div>

    <script>
        function showAlertDialog(title, message, type = 'success') {
            const dialog = document.getElementById('alertDialog');
            const content = document.getElementById('alertDialogContent');
            const titleEl = document.getElementById('alertDialogTitle');
            const messageEl = document.getElementById('alertDialogMessage');
            const iconEl = document.getElementById('alertDialogIcon');
            
            if (!dialog || !content || !titleEl || !messageEl || !iconEl) return;
            
            titleEl.textContent = title;
            messageEl.textContent = message;
            
            // Clear icon classes
            iconEl.className = 'p-3 rounded-full flex items-center justify-center';
            
            if (type === 'success') {
                iconEl.classList.add('bg-emerald-50', 'text-emerald-500');
                iconEl.innerHTML = `
                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                `;
            } else {
                iconEl.classList.add('bg-rose-50', 'text-rose-500');
                iconEl.innerHTML = `
                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                `;
            }
            
            // Display: flex then trigger layout reflow before opacity/transform transitions
            dialog.style.display = 'flex';
            dialog.style.pointerEvents = 'auto';
            
            // Force layout reflow
            dialog.offsetHeight;
            
            dialog.style.opacity = '1';
            content.style.transform = 'scale(1)';
        }
        
        function closeAlertDialog() {
            const dialog = document.getElementById('alertDialog');
            const content = document.getElementById('alertDialogContent');
            
            if (!dialog || !content) return;
            
            dialog.style.opacity = '0';
            content.style.transform = 'scale(0.95)';
            dialog.style.pointerEvents = 'none';
            
            setTimeout(() => {
                dialog.style.display = 'none';
            }, 250);
        }
        
        window.addEventListener('DOMContentLoaded', () => {
            const alerts = document.querySelectorAll('.alert-flash-data');
            if (alerts.length > 0) {
                const el = alerts[0];
                const type = el.getAttribute('data-type');
                const message = el.getAttribute('data-message');
                if (message && message.trim() !== '') {
                    showAlertDialog(type === 'success' ? 'Berhasil' : 'Gagal', message, type);
                }
            }
        });
    </script>
</body>
</html>
