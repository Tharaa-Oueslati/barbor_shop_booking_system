import { Injectable } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';

export type Language = 'en' | 'fr' | 'ar';

@Injectable({
  providedIn: 'root'
})
export class TranslationService {
  private readonly STORAGE_KEY = 'app_language';
  private currentLang: Language = 'en';

  constructor(private translate: TranslateService) {
    this.initializeLanguage();
  }

  private initializeLanguage(): void {
    const savedLang = localStorage.getItem(this.STORAGE_KEY) as Language;
    const browserLang = this.translate.getBrowserLang() as Language;

    if (savedLang && this.isValidLanguage(savedLang)) {
      this.currentLang = savedLang;
    } else if (browserLang && this.isValidLanguage(browserLang)) {
      this.currentLang = browserLang;
    } else {
      this.currentLang = 'en';
    }

    this.translate.use(this.currentLang);
    this.updateDocumentDirection();
  }

  private isValidLanguage(lang: string): lang is Language {
    return ['en', 'fr', 'ar'].includes(lang);
  }

  getCurrentLanguage(): Language {
    return this.currentLang;
  }

  setLanguage(lang: Language): void {
    this.currentLang = lang;
    this.translate.use(lang);
    localStorage.setItem(this.STORAGE_KEY, lang);
    this.updateDocumentDirection();
  }

  private updateDocumentDirection(): void {
    const html = document.documentElement;
    if (this.currentLang === 'ar') {
      html.setAttribute('dir', 'rtl');
      html.setAttribute('lang', 'ar');
    } else {
      html.setAttribute('dir', 'ltr');
      html.setAttribute('lang', this.currentLang);
    }
  }

  isRtl(): boolean {
    return this.currentLang === 'ar';
  }

  getAvailableLanguages(): { code: Language; name: string; flag: string }[] {
    return [
      { code: 'en', name: 'English', flag: '🇬🇧' },
      { code: 'fr', name: 'Français', flag: '🇫🇷' },
      { code: 'ar', name: 'العربية', flag: '🇹🇳' }
    ];
  }
}
