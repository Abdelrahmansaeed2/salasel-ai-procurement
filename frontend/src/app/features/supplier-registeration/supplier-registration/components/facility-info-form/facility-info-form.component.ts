import { AfterViewInit, ChangeDetectionStrategy, Component, EventEmitter, OnInit, Output, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import * as L from 'leaflet';
import { StepHeaderComponent } from '../shared/step-header/step-header.component';
import { FormActionsComponent } from '../shared/form-actions/form-actions.component';
import { LeafletMapService } from '../../services/leaflet-map.service';

@Component({
  selector: 'app-facility-info-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, StepHeaderComponent, FormActionsComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './facility-info-form.component.html',
  styleUrl: './facility-info-form.component.css',
})
export class FacilityInfoFormComponent implements OnInit, AfterViewInit {
  @Output() next = new EventEmitter<any>();
  @Output() back = new EventEmitter<void>();

  form!: FormGroup;
  latitude = signal<number | null>(null);
  longitude = signal<number | null>(null);

  private map!: L.Map;
  private marker!: L.Marker;

  businessTypes = [
    { value: 'llc', label: 'شركة ذات مسؤولية محدودة (LLC)' },
    { value: 'sole', label: 'مؤسسة فردية' },
    { value: 'joint', label: 'شركة مساهمة' },
    { value: 'partnership', label: 'شركة تضامن' },
  ];

  constructor(
    private fb: FormBuilder,
    private mapService: LeafletMapService
  ) {}

  ngOnInit(): void {
    this.form = this.fb.group({
      legalName: ['', [Validators.required, Validators.minLength(3)]],
      businessType: ['', Validators.required],
      registrationNumber: ['', [Validators.required, Validators.pattern(/^\d{10}$/)]],
      address: ['', Validators.required],
    });
  }

  ngAfterViewInit(): void {
    const defaultLat = 30.0444;
    const defaultLng = 31.2357;
    this.latitude.set(defaultLat);
    this.longitude.set(defaultLng);

    const result = this.mapService.createMap('map', [defaultLat, defaultLng], 13, (lat, lng) => {
      this.latitude.set(lat);
      this.longitude.set(lng);
    });

    this.map = result.map;
    this.marker = result.marker;

    this.map.on('click', (e: L.LeafletMouseEvent) => {
      this.mapService.updateMarkerPosition(this.map, this.marker, e.latlng.lat, e.latlng.lng);
      this.latitude.set(e.latlng.lat);
      this.longitude.set(e.latlng.lng);
    });
  }

  locateMe(): void {
    this.mapService.getCurrentLocation()
      .then(({ lat, lng }) => {
        this.latitude.set(lat);
        this.longitude.set(lng);
        this.mapService.updateMarkerPosition(this.map, this.marker, lat, lng);
      })
      .catch(() => {
        alert('تعذر تحديد موقعك تلقائياً. يرجى تفعيل إذن تحديد الموقع أو تحديد موقعك يدوياً على الخريطة.');
      });
  }

  onSubmit(): void {
    if (this.form.valid) {
      this.next.emit({
        ...this.form.value,
        coordinates: {
          lat: this.latitude(),
          lng: this.longitude(),
        },
      });
    } else {
      Object.keys(this.form.controls).forEach(key => {
        this.form.get(key)?.markAsTouched();
      });
    }
  }

  onBack(): void {
    this.back.emit();
  }
}
