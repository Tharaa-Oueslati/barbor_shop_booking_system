import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslationService, Language } from '../../services/translation.service';

@Component({
  selector: 'app-language-switcher',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="relative" (clickOutside)="showDropdown = false">
      <button
        (click)="toggleDropdown()"
        class="flex items-center gap-2 px-3 py-2 rounded-lg bg-gray-100 hover:bg-gray-200 dark:bg-gray-800 dark:hover:bg-gray-700 transition-colors text-sm font-medium"
        [class.bg-gray-200]="showDropdown">
        <span class="text-lg">{{ currentLanguage.flag }}</span>
        <span class="hidden sm:inline">{{ currentLanguage.name }}</span>
        <svg
          class="w-4 h-4 transition-transform"
          [class.rotate-180]="showDropdown"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        </svg>
      </button>

      @if (showDropdown) {
        <div class="absolute right-0 top-full mt-1 bg-white dark:bg-gray-800 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden z-50 min-w-[140px]">
          @for (lang of languages; track lang.code) {
            <button
              (click)="selectLanguage(lang.code)"
              class="w-full flex items-center gap-3 px-4 py-2.5 text-sm hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
              [class.bg-yellow-50]="currentLanguage.code === lang.code"
              [class.text-yellow-700]="currentLanguage.code === lang.code"
              [class.font-semibold]="currentLanguage.code === lang.code">
              <span class="text-lg">{{ lang.flag }}</span>
              <span>{{ lang.name }}</span>
              @if (currentLanguage.code === lang.code) {
                <svg class="w-4 h-4 ml-auto text-yellow-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                </svg>
              }
            </button>
          }
        </div>
      }
    </div>
  `
})
export class LanguageSwitcherComponent {
  showDropdown = false;
  currentLanguage: { code: Language; name: string; flag: string };
  languages: { code: Language; name: string; flag: string }[];

  constructor(private translationService: TranslationService) {
    this.languages = translationService.getAvailableLanguages();
    this.currentLanguage = this.languages.find(l => l.code === translationService.getCurrentLanguage()) || this.languages[0];
  }

  toggleDropdown(): void {
    this.showDropdown = !this.showDropdown;
  }

  selectLanguage(code: Language): void {
    this.translationService.setLanguage(code);
    this.currentLanguage = this.languages.find(l => l.code === code) || this.languages[0];
    this.showDropdown = false;
  }
}
