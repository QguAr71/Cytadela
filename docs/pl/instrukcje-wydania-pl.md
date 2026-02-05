# Instrukcje Wydania

Ten dokument opisuje jak utworzyć nowe wydanie Cytadela.

## 🚀 Automatyczne Wydanie (Zalecane)

### Wymagania wstępne
- Wszystkie testy muszą przejść w CI
- CHANGELOG.md musi być zaktualizowany
- Plik VERSION musi zawierać prawidłową wersję

### Kroki
1. **Zaktualizuj numer wersji:**
   ```bash
   # Zaktualizuj plik VERSION
   echo "3.1.1" > VERSION
   
   # Zaktualizuj wersję w cytadela-core.sh
   sed -i 's/CYTADELA_VERSION=".*"/CYTADELA_VERSION="3.1.1"/' lib/cytadela-core.sh
   
   # Zaktualizuj badges w README jeśli potrzebne
   ```

2. **Zaktualizuj CHANGELOG.md:**
   ```bash
   # Dodaj nową sekcję wersji
   echo "## [3.1.1] - $(date +%Y-%m-%d)" >> CHANGELOG.md
   echo "" >> CHANGELOG.md
   echo "### Bug Fixes" >> CHANGELOG.md
   echo "- Fixed critical issue in module loading" >> CHANGELOG.md
   ```

3. **Commit i tag:**
   ```bash
   git add VERSION CHANGELOG.md lib/cytadela-core.sh README.md
   git commit -m "release: Bump version to 3.1.1"
   git tag -a v3.1.1 -m "Release v3.1.1"
   git push origin main --tags
   ```

4. **Wyzwól wydanie:**
   - GitHub Actions automatycznie utworzy wydanie
   - Sprawdź kartę [Actions](https://github.com/QguAr71/Cytadela/actions)
   - Wydanie zostanie utworzone z auto-generowanym changelog

## 📝 Manualne Wydanie (Fallback)

Jeśli automatyczne wydanie nie powiedzie się, wykonaj te kroki:

1. **Utwórz archiwum źródłowe:**
   ```bash
   VERSION=$(cat VERSION)
   tar --exclude='.git' \
       --exclude='.github' \
       --exclude='legacy' \
       --exclude='*.log' \
       --exclude='tests/reports' \
       -czf "cytadela-${VERSION}.tar.gz" .
   ```

2. **Wygeneruj checksum:**
   ```bash
   sha256sum "cytadela-${VERSION}.tar.gz" > "cytadela-${VERSION}.tar.gz.sha256"
   ```

3. **Utwórz wydanie GitHub:**
   - Przejdź do [strony Releases](https://github.com/QguAr71/Cytadela/releases)
   - Kliknij "Create a new release"
   - Wybierz tag (np. `v3.1.1`)
   - Skopiuj changelog z CHANGELOG.md
   - Prześlij pliki archiwum i checksum

## 📋 Lista Sprawdzania Przed Wydaniem

- [ ] Wszystkie testy CI przechodzą
- [ ] CHANGELOG.md zaktualizowany
- [ ] Plik VERSION zaktualizowany
- [ ] Wersja zaktualizowana w lib/cytadela-core.sh
- [ ] Badges w README zaktualizowane (jeśli potrzebne)
- [ ] Dokumentacja zaktualizowana (jeśli breaking changes)
- [ ] Manualne testowanie zakończone (jeśli możliwe)

## 🏷️ Format Wersji

Cytadela używa [Semantic Versioning](https://semver.org/):
- **MAJOR.MINOR.PATCH** (np. 3.1.0)
- **MAJOR**: Breaking changes
- **MINOR**: Nowe funkcje (kompatybilne wstecz)
- **PATCH**: Poprawki błędów (kompatybilne wstecz)

### Przykłady Wersji
- `3.1.0` - Wydanie major z nowymi funkcjami
- `3.1.1` - Wydanie patch z poprawkami błędów
- `3.2.0` - Wydanie minor z nowymi funkcjami
- `4.0.0` - Major breaking changes

## 🔄 Częstotliwość Wydania

- **Wydania patch**: W miarę potrzeb dla krytycznych błędów
- **Wydania minor**: Co 2-3 miesiące dla funkcji
- **Wydania major**: Co 6-12 miesięcy dla breaking changes

## 📊 Zadania Po Wydaniu

- [ ] Zaktualizuj stronę internetową/dokumentację
- [ ] Ogłoś w mediach społecznościowych (opcjonalnie)
- [ ] Monitoruj issues dla nowych błędów
- [ ] Zaktualizuj repozytoria pakietów (AUR, itp.)

## 🆘 Rozwiązywanie Problemów

### Workflow Wydania Nie Powoduje się
1. Sprawdź kartę Actions dla szczegółów błędu
2. Zweryfikuj format tag (musi być `vX.Y.Z`)
3. Zapewnij że plik VERSION pasuje do tag
4. Sprawdź konflikty merge

### Problemy z Generowaniem Changelog
1. Zweryfikuj dostępność historii git
2. Sprawdź nieprawidłowe komunikaty commit
3. Można dodać manualny wpis changelog

### Niepowodzenie Przesyłania Assetów
1. Sprawdź rozmiar pliku (< 2GB limit GitHub)
2. Zweryfikuj uprawnienia plików
3. Manualne przesłanie przez UI GitHub

---

**Pamiętaj:** Zawsze testuj dokładnie przed wydaniem! 🧪
